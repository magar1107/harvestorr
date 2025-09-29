import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as bcrypt from "bcryptjs";

admin.initializeApp();
const db = admin.database();
const fcm = admin.messaging();

interface Telemetry {
  ptoRpm?: number;
  tankLevelPct?: number;
  suctionPressure?: number;
  baleCount?: number;
  moisturePct?: number;
}

export const ingestTelemetry = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

  try {
    const { deviceId, deviceKey, ts, telemetry, status } = req.body || {};
    if (!deviceId || !deviceKey || !telemetry) return res.status(400).send("Bad payload");

    const regSnap = await db.ref(`/deviceRegistry/${deviceId}`).get();
    if (!regSnap.exists()) return res.status(403).send("Unknown device");
    const reg = regSnap.val();
    if (reg.active !== true) return res.status(403).send("Device inactive");

    const storedHash = reg.deviceKey as string | undefined;
    if (!storedHash) return res.status(403).send("No device key");
    const ok = storedHash.startsWith("$2") ? bcrypt.compareSync(deviceKey, storedHash) : deviceKey === storedHash;
    if (!ok) return res.status(403).send("Invalid key");

    const ownerUid: string = reg.ownerUid;
    const now = typeof ts === "number" && ts > 0 ? ts : Date.now();

    const t: Telemetry = telemetry as Telemetry;

    const updates: Record<string, any> = {};
    updates[`/devices/${deviceId}/telemetry/${now}`] = { ts: now, ...t };
    updates[`/live/${deviceId}`] = { ts: now, ...t };
    updates[`/devices/${deviceId}/status`] = { ...(status || {}), lastSeen: now, online: true };

    // Alerts
    const alerts: { type: string; severity: string; message: string }[] = [];
    if (typeof t.tankLevelPct === "number") {
      if (t.tankLevelPct >= 98) alerts.push({ type: "TANK_FULL", severity: "critical", message: "Tank full" });
      else if (t.tankLevelPct >= 90) alerts.push({ type: "TANK_NEAR_FULL", severity: "warning", message: "Tank 90% full" });
    }
    if (typeof t.ptoRpm === "number" && t.ptoRpm > 1100) {
      alerts.push({ type: "PTO_OVERLOAD", severity: "warning", message: "PTO overload" });
    }
    if (typeof t.suctionPressure === "number") {
      if (t.suctionPressure < 35) alerts.push({ type: "BLOCKAGE", severity: "warning", message: "Suction low" });
      if (t.suctionPressure > 85) alerts.push({ type: "BLOCKAGE", severity: "warning", message: "Suction high" });
    }

    const alertsPath = `/devices/${deviceId}/alerts`;
    for (const a of alerts) {
      const id = db.ref().push().key!;
      updates[`${alertsPath}/${id}`] = { ts: now, ...a };
    }

    await db.ref().update(updates);

    if (alerts.length && ownerUid) {
      const tokensSnap = await db.ref(`/notifications/deviceTokens/${ownerUid}`).get();
      if (tokensSnap.exists()) {
        const tokens = Object.keys(tokensSnap.val() || {});
        if (tokens.length) {
          await fcm.sendEachForMulticast({
            tokens,
            notification: { title: "Harvester Alert", body: alerts.map(a => a.message).join(", ") },
            data: { deviceId, ts: String(now) },
          });
        }
      }
    }

    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).send("Server error");
  }
});

export const dailyAggregate = functions.pubsub.schedule("every day 23:59").onRun(async () => {
  // Compute previous day's aggregates in UTC (midnight to midnight)
  const now = new Date();
  const prev = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const dayEnd = prev.getTime(); // today's 00:00 UTC
  const dayStart = dayEnd - 24 * 60 * 60 * 1000; // yesterday 00:00 UTC
  const y = new Date(dayStart).toISOString().slice(0, 10);

  const devicesSnap = await db.ref("/devices").get();
  if (!devicesSnap.exists()) return null;

  const updates: Record<string, any> = {};

  const deviceIds: string[] = [];
  devicesSnap.forEach((dev) => {
    if (dev.key) deviceIds.push(dev.key);
    return false;
  });

  for (const deviceId of deviceIds) {
    const teleRef = db.ref(`/devices/${deviceId}/telemetry`).orderByKey().startAt(String(dayStart)).endAt(String(dayEnd - 1));
    const teleSnap = await teleRef.get();
    if (!teleSnap.exists()) continue;

    let totalBales = 0;
    let lastBaleCount: number | null = null;
    let sumMoist = 0;
    let moistCount = 0;
    let runMillis = 0;
    let lastTs: number | null = null;
    let lastActive = false;
    let grainKg = 0;

    teleSnap.forEach((child) => {
      const ts = parseInt(child.key || "0", 10);
      const v = child.val() || {} as any;
      const rpm = typeof v.ptoRpm === 'number' ? v.ptoRpm as number : 0;
      const baleCount = typeof v.baleCount === 'number' ? v.baleCount as number : undefined;
      const moisture = typeof v.moisturePct === 'number' ? v.moisturePct as number : undefined;
      const grainInc = typeof v.grainKgIncrement === 'number' ? v.grainKgIncrement as number : 0;

      // Bales from deltas
      if (typeof baleCount === 'number') {
        if (lastBaleCount == null) {
          lastBaleCount = baleCount;
        } else if (baleCount >= lastBaleCount) {
          totalBales += (baleCount - lastBaleCount);
          lastBaleCount = baleCount;
        } else {
          // counter reset; treat as new cycle
          lastBaleCount = baleCount;
        }
      }

      // Moisture average
      if (typeof moisture === 'number') {
        sumMoist += moisture;
        moistCount += 1;
      }

      // Grain kg (optional incremental counter)
      if (grainInc > 0) grainKg += grainInc;

      // Run hours accumulate while active
      const active = rpm > 0; // threshold can be tuned
      if (lastTs != null) {
        const dt = Math.max(0, ts - lastTs);
        if (lastActive) runMillis += dt;
      }
      lastTs = ts;
      lastActive = active;
      return false;
    });

    const avgMoist = moistCount > 0 ? sumMoist / moistCount : 0;
    const runHours = runMillis / (1000 * 60 * 60);

    updates[`/aggregates/daily/${deviceId}/${y}`] = {
      grainKg,
      bales: totalBales,
      avgMoisture: Number(avgMoist.toFixed(2)),
      runHours: Number(runHours.toFixed(2)),
      lastTs: dayEnd,
    };
  }

  if (Object.keys(updates).length) await db.ref().update(updates);
  return null;
});

export const requestCommand = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Auth required');
  }
  const deviceId = (data?.deviceId as string || '').trim();
  const type = (data?.type as string || '').trim();
  if (!deviceId || !type) {
    throw new functions.https.HttpsError('invalid-argument', 'deviceId and type are required');
  }

  // Check user is linked to device
  const linkSnap = await db.ref(`/users/${uid}/devices/${deviceId}`).get();
  if (!linkSnap.exists() || linkSnap.val() !== true) {
    throw new functions.https.HttpsError('permission-denied', 'Not linked to this device');
  }

  // Basic allowlist of command types
  const allowed = new Set(['UNLOAD_TANK', 'PAUSE_ALERTS']);
  if (!allowed.has(type)) {
    throw new functions.https.HttpsError('invalid-argument', 'Unknown command type');
  }

  const ts = Date.now();
  const cmdId = db.ref().push().key!;
  const cmd = { ts, type, uid, status: 'queued' };
  const updates: Record<string, any> = {};
  updates[`/devices/${deviceId}/commands/${cmdId}`] = cmd;
  updates[`/commandRequests/${uid}/${cmdId}`] = { deviceId, ...cmd };
  await db.ref().update(updates);

  return { cmdId };
});
