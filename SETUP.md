# DP Football AI — Free API setup

1. Sign up at https://www.football-data.org/ and get a free API token.
2. Create a Cloudflare Worker project containing `backend/worker/index.js` and `backend/worker/wrangler.toml`. Deploy using Wrangler (`npx wrangler deploy` from the backend/worker folder).
3. Store the token as a Worker secret: `npx wrangler secret put FOOTBALL_DATA_TOKEN` (run from backend/worker).
4. In GitHub Actions, build Flutter with `flutter build apk --debug --dart-define=PREDICTION_API_URL=https://YOUR-WORKER.workers.dev`.
5. Add `http: ^1.3.0` to pubspec (already included in replacement).
6. Never commit your token or put it in a Flutter `--dart-define`.

The free provider offers limited competitions and delayed scores. The worker analyzes only fixtures verifiable in the next 21 days. The probabilities are baseline Poisson estimates, not a generative AI model, and should be evaluated against historical results before launch.

IMPORTANT: Public Worker endpoints can be abused. Before public launch, configure Cloudflare rate limiting, bot protection and app authentication; monitor upstream request quotas. Caching reduces but does not eliminate the risk. Do not promote this as live real-time data.
