# Fixes Applied for GroupMe API Compatibility

These changes make the bridge work with the **current GroupMe v3 API** and harden it against missing or inconsistent data.

---

## 1. Critical: `/users/me` response (linking & DMs)

**Problem:** GroupMe v3 returns `id`, not `user_id`. The bridge used `user_id`, so `userId` was `undefined` and linking/DMs failed.

**Fix:**
- **`src/client.ts`:** Set `userId` from `me.id ?? me.user_id` and coerce to string.
- **`src/groupme.ts`:** Same for `p.data.userId` in `newPuppet`.

---

## 2. createUser: GroupMe v3 and ID handling

**Problem:** v3 uses `group.id`; the code used `group.group_id` (undefined). Strict `===` between API ids (sometimes numbers) and bridge ids (strings) could fail. Missing `profile` or `group.members` could throw.

**Fix:**
- Use `group.id ?? group.group_id` for room override keys.
- Normalize IDs: `String(dm.other_user.id) === userIdStr`, `String(member.user_id) === userIdStr`.
- Use `(group.members || [])` so missing members don’t throw.
- Only add room overrides when `profile && groupProfile && groupId`.
- Use `groupProfile.nickname ?? groupProfile.name` for display name.

---

## 3. Null safety

**Problem:** `message.subject.attachments` can be undefined → crash on `.map()`. `group.members` can be missing in some responses.

**Fix:**
- **handleGroupMeMessage:** `(message.subject.attachments || []).map(...)`.
- **createUser / listUsers:** `(group.members || [])` when iterating.

---

## 4. listUsers: IDs and names

**Problem:** API may return numeric ids; bridge expects consistent string ids. Member display name might be `nickname` or `name`.

**Fix:**
- Emit `id: String(member.user_id)` and `id: String(dm.other_user.id)`.
- Use `member.nickname ?? member.name` for list display.

---

## 5. Read receipts

**Problem:** v2 `read_receipts` endpoint may be deprecated; failures were already caught.

**Fix:** Comment added that v2 may be deprecated; behavior unchanged (try/catch kept).

---

## 6. Dependencies

**Fix:** `axios` bumped from `^0.27.0` to `^1.6.0` in `package.json` for security (CVEs in older versions).

---

## After pulling these fixes

1. Run `npm install` (to get axios 1.6).
2. Run `npm run build`.
3. Configure `config.yaml` and register the appservice with Synapse.
4. Start the bridge with `npm run start` and link with your GroupMe access token from [dev.groupme.com](https://dev.groupme.com).
