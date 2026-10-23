
const FOOTBALL_API = 'https://api.football-data.org/v4';

const COMPETITIONS = ['PL', 'PD', 'BL1', 'SA', 'FL1', 'CL'];

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), { status, headers });
}

function normalize(value) {
  return String(value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\b(fc|cf|afc|sc|ac|club|football)\b/g, '')
    .replace(/[^a-z0-9]/g, '')
    .trim();
}

function teamMatches(input, team) {
  const query = normalize(input);
  const candidates = [
    team?.name,
    team?.shortName,
    team?.tla,
  ].filter(Boolean);

  return candidates.some((name) => {
    const normalized = normalize(name);
    return normalized === query ||
      (query.length >= 4 && normalized.includes(query)) ||
      (normalized.length >= 4 && query.includes(normalized));
  });
}

async function footballFetch(path, env) {
  if (!env.FOOTBALL_DATA_TOKEN) {
    throw new Error('FOOTBALL_DATA_TOKEN is not configured.');
  }

  const response = await fetch(`${FOOTBALL_API}${path}`, {
    headers: {
      'X-Auth-Token': env.FOOTBALL_DATA_TOKEN,
    },
  });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(
      `Football API returned ${response.status}: ${details.slice(0, 200)}`
    );
  }

  return response.json();
}

function dateString(date) {
  return date.toISOString().slice(0, 10);
}

async function getFixtures(env, days = 7) {
  const today = new Date();
  const until = new Date(today.getTime() + days * 86400000);

  const fromDate = dateString(today);
  const toDate = dateString(until);

  const results = await Promise.allSettled(
    COMPETITIONS.map(async (competition) => {
      const data = await footballFetch(
        `/competitions/${competition}/matches?dateFrom=${fromDate}&dateTo=${toDate}`,
        env
      );
      return data.matches || [];
    })
  );

  const matches = [];
  const errors = [];

  results.forEach((result, index) => {
    if (result.status === 'fulfilled') {
      matches.push(...result.value);
    } else {
      errors.push({
        competition: COMPETITIONS[index],
        message: result.reason?.message || 'Unknown error',
      });
    }
  });

  if (results.every((result) => result.status === 'rejected')) {
    throw new Error(
      `Unable to retrieve fixtures: ${errors.map((e) => e.message).join('; ')}`
    );
  }

  const unique = new Map();

  for (const match of matches) {
    if (!match.id || !match.utcDate) continue;
    if (new Date(match.utcDate).getTime() < today.getTime()) continue;
    unique.set(match.id, match);
  }

  return {
    fixtures: [...unique.values()]
      .sort((a, b) => new Date(a.utcDate) - new Date(b.utcDate))
      .map((match) => ({
        id: match.id,
        competition: match.competition?.name || '',
        competitionCode: match.competition?.code || '',
        kickoff: match.utcDate,
        status: match.status,
        home: match.homeTeam?.name || '',
        away: match.awayTeam?.name || '',
        homeLogo: match.homeTeam?.crest || '',
        awayLogo: match.awayTeam?.crest || '',
      })),
    errors,
  };
}

async function analyzeFixture(home, away, env) {
  const data = await getFixtures(env, 21);

  const match = data.fixtures.find(
    (fixture) =>
      teamMatches(home, { name: fixture.home }) &&
      teamMatches(away, { name: fixture.away })
  );

  if (!match) {
    return {
      status: 'not_found',
      message:
        'No verified upcoming fixture found in supported competitions within 21 days.',
    };
  }

  return {
    status: 'found',
    fixture: match,
    message:
      'Fixture verified. Prediction probabilities require a statistical model and verified team data.',
  };
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers });
    }

    const url = new URL(request.url);

    if (url.pathname === '/health' && request.method === 'GET') {
      return json({
        status: 'ok',
        service: 'DP Football AI',
      });
    }

    if (url.pathname === '/fixtures' && request.method === 'GET') {
      try {
        const requestedDays = Number(url.searchParams.get('days') || 7);
        const days = Number.isFinite(requestedDays)
          ? Math.max(1, Math.min(21, Math.floor(requestedDays)))
          : 7;

        const result = await getFixtures(env, days);

        return json({
          status: 'ok',
          source: 'football-data.org',
          days,
          count: result.fixtures.length,
          fixtures: result.fixtures,
          errors: result.errors,
        });
      } catch (error) {
        return json({
          status: 'error',
          message: error.message,
        }, 502);
      }
    }

    if (url.pathname === '/analyze' && request.method === 'POST') {
      try {
        const body = await request.json();
        const home = String(body.home || '').trim();
        const away = String(body.away || '').trim();

        if (!home || !away) {
          return json({
            status: 'error',
            message: 'Both home and away teams are required.',
          }, 400);
        }

        return json(await analyzeFixture(home, away, env));
      } catch (error) {
        return json({
          status: 'error',
          message: error.message,
        }, 502);
      }
    }

    return json({
      status: 'not_found',
      message: 'Endpoint not found.',
    }, 404);
  },
};
