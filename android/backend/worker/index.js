
// Cloudflare Worker: deploy with secret FOOTBALL_DATA_TOKEN.
const API = 'https://api.football-data.org/v4';
const CODES = ['PL','PD','BL1','SA','FL1','DED'];
const json = (body, status=200) => new Response(JSON.stringify(body), {status, headers:{'content-type':'application/json; charset=utf-8','cache-control':'no-store'}});
const clean = s => String(s || '').toLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g,'').replace(/\b(fc|cf|afc|club|football|the)\b/g,'').replace(/[^a-z0-9]/g,'').trim();

async function fetchApi(path, env, ttl=900) {
 const cache = caches.default;
 const key = new Request(`https://dp-cache.invalid${path}`);
 const hit = await cache.match(key); if(hit) return hit.json();
 const response = await fetch(`${API}${path}`, {headers:{'X-Auth-Token':env.FOOTBALL_DATA_TOKEN}});
 if(!response.ok) throw new Error(response.status===429?'Football provider rate limit reached':`Football provider error (${response.status})`);
 const data = await response.json();
 await cache.put(key, new Response(JSON.stringify(data), {headers:{'Cache-Control':`public, max-age=${ttl}`,'content-type':'application/json'}}));
 return data;
}

function poisson(lambda,k){let p=Math.exp(-lambda); for(let i=1;i<=k;i++)p*=lambda/i; return p;}

function prediction(home,away,history,fixture){
 const completed=history.filter(m=>m.status==='FINISHED'&&Number.isInteger(m.score?.fullTime?.home)&&Number.isInteger(m.score?.fullTime?.away));
 const teamGames=(id)=>completed.filter(m=>m.homeTeam?.id===id||m.awayTeam?.id===id).sort((a,b)=>Date.parse(b.utcDate)-Date.parse(a.utcDate)).slice(0,10);
 const hs=teamGames(home.id), as=teamGames(away.id);
 if(hs.length<5||as.length<5)return {status:'insufficient_data',message:'At least five completed matches per team are required.',homeMatches:hs.length,awayMatches:as.length};
 const averages=(games,id)=>{let scored=0,conceded=0; for(const m of games){const isHome=m.homeTeam.id===id; scored+=isHome?m.score.fullTime.home:m.score.fullTime.away;conceded+=isHome?m.score.fullTime.away:m.score.fullTime.home;}return {scored:scored/games.length,conceded:conceded/games.length};};
 const h=averages(hs,home.id),a=averages(as,away.id);
 const xh=Math.max(.2,Math.min(4,(h.scored+a.conceded)/2*1.08));
 const xa=Math.max(.2,Math.min(4,(a.scored+h.conceded)/2*.92));
 let hw=0,dr=0,aw=0,btts=0,over15=0,over25=0;const scores=[];
 for(let i=0;i<=12;i++)for(let j=0;j<=12;j++){const p=poisson(xh,i)*poisson(xa,j);if(i>j)hw+=p;else if(i===j)dr+=p;else aw+=p;if(i>0&&j>0)btts+=p;if(i+j>=2)over15+=p;if(i+j>=3)over25+=p;scores.push({score:`${i}-${j}`,probability:p});}
 const total=hw+dr+aw;const probs={home:hw/total,draw:dr/total,away:aw/total};scores.sort((x,y)=>y.probability-x.probability);
 const pct=x=>Math.round(x*1000)/10;
 return {status:'ready',model:'Independent Poisson goals (baseline)',home:home.name,away:away.name,fixtureId:fixture.id,kickoff:fixture.utcDate,competition:fixture.competition?.name,probabilities:{home:pct(probs.home),draw:pct(probs.draw),away:pct(probs.away)},markets:{over15:pct(over15),over25:pct(over25),bttsYes:pct(btts),doubleChance1X:pct(probs.home+probs.draw),doubleChanceX2:pct(probs.away+probs.draw)},expectedGoals:{home:Math.round(xh*100)/100,away:Math.round(xa*100)/100},likelyScores:scores.slice(0,3).map(s=>({score:s.score,probability:pct(s.probability)})),sample:{homeMatches:hs.length,awayMatches:as.length,homeScored:h.scored,homeConceded:h.conceded,awayScored:a.scored,awayConceded:a.conceded},notice:'Statistical estimate, not a guarantee. Injuries, lineups and other context are not included.'};
}

export default {async fetch(request,env){
 if(request.method!=='POST')return json({error:'Use POST /analyze'},405);
 const url=new URL(request.url);if(url.pathname!=='/analyze')return json({error:'Not found'},404);
 if(!env.FOOTBALL_DATA_TOKEN)return json({error:'Server is not configured'},503);
 try{
  const input=await request.json();const homeName=String(input.home||'').trim(),awayName=String(input.away||'').trim();
  if(!homeName||!awayName||homeName.length>80||awayName.length>80)return json({error:'Provide valid home and away team names'},400);
  const today=new Date();const start=today.toISOString().slice(0,10);const end=new Date(today.getTime()+21*86400000).toISOString().slice(0,10);
  // Sequential requests to respect free tier; cache each competition response.
  let fixture=null, history=null;
  for(const code of CODES){
   let upcoming; try { upcoming=await fetchApi(`/competitions/${code}/matches?dateFrom=${start}&dateTo=${end}`,env,1800); } catch(e) { if(String(e).includes('(403)')||String(e).includes('(404)')) continue; throw e; }
   const matches=upcoming.matches||[];
   fixture=matches.find(m=>{const h=clean(m.homeTeam?.name),a=clean(m.awayTeam?.name),x=clean(homeName),y=clean(awayName);return (h===x||h.includes(x)||x.includes(h))&&(a===y||a.includes(y)||y.includes(a));});
   if(fixture){const pastStart=new Date(today.getTime()-180*86400000).toISOString().slice(0,10);history=(await fetchApi(`/competitions/${code}/matches?dateFrom=${pastStart}&dateTo=${start}`,env,3600)).matches||[];break;}
  }
  if(!fixture)return json({status:'not_found',message:'No verified upcoming fixture found in supported competitions within 21 days.'});
  return json(prediction(fixture.homeTeam,fixture.awayTeam,history,fixture));
 }catch(e){return json({error:e instanceof Error?e.message:'Analysis failed'},502);}
}};
