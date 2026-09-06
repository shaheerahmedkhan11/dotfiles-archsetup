const express = require('express');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { marked } = require('marked');
const zlib = require('zlib');

const app = express();
const PORT = process.env.CYBER_HUB_PORT || 7777;

// ── Vault roots ────────────────────────────────────────────────────────
const USER_HOME = process.env.USERPROFILE || process.env.HOME || os.homedir();
const H = path.join(USER_HOME, 'AI History Vault');
const A = path.join(USER_HOME, 'AI-OS');
const VAULTS = { history: H, 'ai-os': A };
const TOOLS = ['claude', 'cursor', 'codex', 'antigravity', 'hermes', 'opencode', 'copilot', 'agent'];
const BACKUP_DIR_H = path.join(H, '09 - Tools', 'State', 'backups');
const BACKUP_DIR_A = path.join(A, '.backups');
const SCRATCH = path.join(H, '09 - Tools', 'State', 'scratch-pad.md');

// ── Middleware ──────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb', strict: false }));

// ── Cache headers for static assets ────────────────────────────────────
app.use(express.static(path.join(__dirname, 'public'), {
  maxAge: '1h',
  etag: true,
  lastModified: true,
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.html')) {
      res.setHeader('Cache-Control', 'no-cache');
    } else if (filePath.match(/\.(js|css)$/)) {
      res.setHeader('Cache-Control', 'public, max-age=3600');
    } else if (filePath.match(/\.(png|jpg|gif|svg|ico|woff2?)$/)) {
      res.setHeader('Cache-Control', 'public, max-age=86400');
    }
  }
}));

// ── Gzip compression ───────────────────────────────────────────────────
app.use((req, res, next) => {
  const accept = req.headers['accept-encoding'] || '';
  if (!accept.includes('gzip')) return next();
  const origJson = res.json.bind(res);
  res.json = (data) => {
    const body = JSON.stringify(data);
    if (body.length < 512) return origJson(data);
    zlib.gzip(Buffer.from(body), { level: 6 }, (err, compressed) => {
      if (err) return origJson(data);
      res.setHeader('Content-Encoding', 'gzip');
      res.setHeader('Content-Type', 'application/json');
      res.setHeader('Content-Length', compressed.length);
      res.end(compressed);
    });
    return res;
  };
  next();
});

// ── Request timing + logging ───────────────────────────────────────────
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - start;
    if (ms > 100 || res.statusCode >= 400) {
      const status = res.statusCode;
      const color = status >= 500 ? '\x1b[31m' : status >= 400 ? '\x1b[33m' : '\x1b[32m';
      console.log(`  ${color}${req.method}\x1b[0m ${req.path} \x1b[90m${status} ${ms}ms\x1b[0m`);
    }
  });
  next();
});

// ── Helpers ────────────────────────────────────────────────────────────
const exists = p => { try { return fs.existsSync(p); } catch { return false; } };
const read = (rel, v = H) => { if (!safePath(rel, v)) return null; const f = path.join(v, rel); return exists(f) ? fs.readFileSync(f, 'utf-8') : null; };
const write = (rel, c, v = H) => {
  if (!safePath(rel, v)) return;
  const f = path.join(v, rel);
  fs.mkdirSync(path.dirname(f), { recursive: true });
  fs.writeFileSync(f, c, 'utf-8');
};
const remove = (rel, v = H) => { if (!safePath(rel, v)) return false; const f = path.join(v, rel); if (exists(f)) { fs.unlinkSync(f); return true; } return false; };

const backupDir = v => v === A ? BACKUP_DIR_A : BACKUP_DIR_H;
const backup = (rel, v = H) => {
  const c = read(rel, v); if (!c) return;
  const slug = rel.replace(/[\/\\]/g, '_').replace(/\.md$/, '');
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const dir = backupDir(v);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, `${slug}_${ts}.md`), c, 'utf-8');
};

const walk = (dir, ext = '.md', depth = 0, vault = H) => {
  const full = path.join(vault, dir);
  if (!exists(full)) return [];
  const results = [];
  const visited = new Set();
  const recurse = (d, currentDepth) => {
    if (currentDepth > 4) return;
    const real = fs.realpathSync(d);
    if (visited.has(real)) return;
    visited.add(real);
    let entries;
    try { entries = fs.readdirSync(d, { withFileTypes: true }); } catch { return; }
    for (const ent of entries) {
      if (ent.name.startsWith('.')) continue;
      const fp = path.join(d, ent.name);
      try {
        if (ent.isDirectory()) { recurse(fp, currentDepth + 1); continue; }
        if (ext && !ent.name.endsWith(ext)) continue;
        const s = fs.statSync(fp);
        results.push({ name: ent.name, path: path.relative(vault, fp).replace(/\\/g, '/'), size: s.size, modified: s.mtime.toISOString() });
      } catch { continue; }
    }
  };
  recurse(full, depth);
  return results.sort((a, b) => b.modified.localeCompare(a.modified));
};

const fm = c => {
  const m = c.match(/^---\n([\s\S]*?)\n---/);
  if (!m) return { meta: {}, body: c };
  const meta = {};
  for (const l of m[1].split('\n')) {
    const i = l.indexOf(':');
    if (i > 0) {
      const key = l.slice(0, i).trim();
      let val = l.slice(i + 1).trim();
      try {
        if (val.startsWith('[') || val.startsWith('"') || val.startsWith('{')) val = JSON.parse(val);
      } catch {}
      meta[key] = val;
    }
  }
  return { meta, body: c.slice(m[0].length).trim() };
};

const render = (rel, v = H) => {
  if (!safePath(rel, v)) return null;
  const c = read(rel, v);
  if (!c) return null;
  const { meta, body } = fm(c);
  return { meta, body, raw: c, html: marked(body) };
};

const json = (res, d) => res.json(d);
const err = (res, msg, code = 400) => res.status(code).json({ error: msg });
const safe = fn => (req, res) => { try { fn(req, res); } catch (e) { console.error('  \x1b[31mERR\x1b[0m', e.message); err(res, e.message, 500); } };

const vaultFor = v => v === 'ai-os' ? A : H;
const sanitize = s => (s || '').replace(/[<>]/g, '').replace(/&/g, '&amp;').replace(/"/g, '&quot;');
const safePath = (rel, v) => {
  const resolved = path.resolve(v, rel);
  const vault = path.resolve(v);
  return resolved.startsWith(vault + path.sep) || resolved === vault;
};

// ── Health ─────────────────────────────────────────────────────────────
app.get('/api/health', (_, res) => json(res, {
  status: 'ok',
  uptime: Math.floor(process.uptime()),
  vaults: { history: exists(H), 'ai-os': exists(A) },
  timestamp: new Date().toISOString()
}));

// ── Stats ──────────────────────────────────────────────────────────────
app.get('/api/stats', safe((_, res) => {
  const sd = path.join(H, '02 - Session History', 'by-tool');
  const sc = {}; let total = 0;
  for (const t of TOOLS) {
    const td = path.join(sd, t);
    const n = exists(td) ? fs.readdirSync(td).filter(f => f.endsWith('.md')).length : 0;
    sc[t] = n; total += n;
  }
  const skills = exists(path.join(A, '02 - Skills')) ? fs.readdirSync(path.join(A, '02 - Skills')).filter(f => f.endsWith('.md')).map(f => {
    const { meta } = fm(read(`02 - Skills/${f}`, A) || '');
    return { name: f.replace('.md', ''), level: meta.mastery_level || 0, progress: meta.progress || 0, status: meta.status || 'Unknown' };
  }) : [];
  const dl = exists(path.join(A, '06 - Daily Logs')) ? fs.readdirSync(path.join(A, '06 - Daily Logs')).filter(f => f.endsWith('.md')).length : 0;
  const pj = exists(path.join(H, '03 - Projects')) ? fs.readdirSync(path.join(H, '03 - Projects')).filter(f => f.endsWith('.md')).length : 0;
  const tn = exists(path.join(H, '06 - Tool Notes')) ? fs.readdirSync(path.join(H, '06 - Tool Notes')).filter(f => f.endsWith('.md')).length : 0;
  const bkH = exists(BACKUP_DIR_H) ? fs.readdirSync(BACKUP_DIR_H).filter(f => f.endsWith('.md')).length : 0;
  const bkA = exists(BACKUP_DIR_A) ? fs.readdirSync(BACKUP_DIR_A).filter(f => f.endsWith('.md')).length : 0;

  const recentSessions = [];
  for (const t of TOOLS) {
    const td = path.join(sd, t);
    if (!exists(td)) continue;
    for (const f of fs.readdirSync(td).filter(f => f.endsWith('.md')).slice(0, 3)) {
      try {
        const fp = path.join(td, f);
        const s = fs.statSync(fp);
        recentSessions.push({ tool: t, filename: f, modified: s.mtime.toISOString() });
      } catch {}
    }
  }
  recentSessions.sort((a, b) => b.modified.localeCompare(a.modified));

  json(res, {
    sessionCounts: sc, totalSessions: total, skills, dailyLogs: dl, projects: pj, toolNotes: tn,
    backups: bkH + bkA, recentSessions: recentSessions.slice(0, 5),
    vaultHistory: H, vaultAiOs: A
  });
}));

// ── Sessions ───────────────────────────────────────────────────────────
app.get('/api/sessions', safe((req, res) => {
  const filter = req.query.tool || 'all';
  const limit = parseInt(req.query.limit) || 200;
  const tools = filter === 'all' ? TOOLS : [filter];
  const sessions = [];
  for (const t of tools) {
    const td = path.join(H, '02 - Session History/by-tool', t);
    if (!exists(td)) continue;
    for (const f of fs.readdirSync(td).filter(f => f.endsWith('.md'))) {
      try {
        const fp = path.join(td, f);
        const s = fs.statSync(fp);
        const content = fs.readFileSync(fp, 'utf-8');
        const { meta, body } = fm(content);
        const summaryMatch = body.match(/## Summary\n\n(.+)/);
        sessions.push({
          tool: t, path: `02 - Session History/by-tool/${t}/${f}`, filename: f,
          title: meta.title || f.replace('.md', ''), date: meta.date || '',
          modified: s.mtime.toISOString(), size: s.size,
          summary: summaryMatch ? summaryMatch[1] : ''
        });
      } catch { continue; }
    }
  }
  json(res, sessions.sort((a, b) => b.modified.localeCompare(a.modified)).slice(0, limit));
}));

app.get('/api/session/*', safe((req, res) => {
  const r = render(req.params[0]);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/session/*', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  backup(req.params[0]);
  write(req.params[0], req.body.content);
  json(res, { ok: true });
}));

app.delete('/api/session/*', safe((req, res) => {
  backup(req.params[0]);
  remove(req.params[0]) ? json(res, { ok: true }) : err(res, 'Not found', 404);
}));

app.post('/api/new-session', safe((req, res) => {
  const { tool, title, summary, transcript } = req.body;
  if (!tool || !TOOLS.includes(tool)) return err(res, 'Invalid tool');
  const now = new Date();
  const d = now.toISOString().slice(0, 10);
  const t = now.toTimeString().slice(0, 8).replace(/:/g, '-');
  const slug = (title || 'session').toLowerCase().replace(/[^a-z0-9]+/g, '_').slice(0, 60);
  const fn = `${d}_${t}_${tool}_${slug}.md`;
  const dir = path.join(H, '02 - Session History/by-tool', tool);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, fn), [
    '---',
    `tags: [ai-session, manual, ${tool}]`,
    `tool: ${tool}`,
    `date: ${d}`,
    `session_id: manual-${Date.now()}`,
    `title: ${sanitize(title)}`,
    '---',
    '',
    `# ${title || 'Session'}`,
    '',
    `- **Tool:** ${tool}`,
    `- **Date:** ${now.toISOString().replace('T', ' ').slice(0, 19)}`,
    '',
    '## Summary',
    '',
    summary || '',
    '',
    '## Transcript / Notes',
    '',
    transcript || '',
    '',
    '---',
    '*Saved via Cyber-Hub*'
  ].join('\n'), 'utf-8');
  json(res, { ok: true, path: `02 - Session History/by-tool/${tool}/${fn}` });
}));

app.post('/api/duplicate-session', safe((req, res) => {
  const { path: src } = req.body;
  if (!src) return err(res, 'Source path required');
  const c = read(src); if (!c) return err(res, 'Source not found', 404);
  const now = new Date();
  const d = now.toISOString().slice(0, 10);
  const t = now.toTimeString().slice(0, 8).replace(/:/g, '-');
  const fn = path.basename(src).replace(/^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/, `${d}_${t}`);
  const tool = (src.match(/by-tool\/([^/]+)\//) || [])[1] || 'opencode';
  const dir = path.join(H, '02 - Session History/by-tool', tool);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, fn), c, 'utf-8');
  json(res, { ok: true });
}));

// ── Projects ───────────────────────────────────────────────────────────
app.get('/api/projects', safe((_, res) => {
  json(res, walk('03 - Projects').map(f => {
    const { meta, body } = fm(read(f.path) || '');
    return { ...f, meta, snippet: body.slice(0, 200) };
  }));
}));

app.get('/api/project/*', safe((req, res) => {
  const r = render(req.params[0]);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.post('/api/project', safe((req, res) => {
  const { name, domain, tech, description } = req.body;
  if (!name || !name.trim()) return err(res, 'Project name required');
  const d = new Date().toISOString().slice(0, 10);
  write(`03 - Projects/${name.trim()}.md`, [
    '---',
    'tags: [project]',
    'status: Planning',
    `domain: ${domain || ''}`,
    `tech: [${(tech || '').split(',').map(t => `"${t.trim()}"`).join(', ')}]`,
    `date: ${d}`,
    '---',
    '',
    `# ${name.trim()}`,
    '',
    `**Status:** Planning | **Start:** ${d} | **Domain:** ${domain || 'TBD'}`,
    '',
    '## Overview',
    '',
    description || '',
    '',
    '## Skills Demonstrated',
    '',
    '- [ ]',
    '',
    '## What I Learned',
    '',
    '-'
  ].join('\n'));
  json(res, { ok: true });
}));

app.put('/api/project/*', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  backup(req.params[0]);
  write(req.params[0], req.body.content);
  json(res, { ok: true });
}));

app.delete('/api/project/*', safe((req, res) => {
  backup(req.params[0]);
  remove(req.params[0]) ? json(res, { ok: true }) : err(res, 'Not found', 404);
}));

// ── Daily Logs ─────────────────────────────────────────────────────────
app.get('/api/daily-logs', safe((_, res) => {
  const prefix = '06 - Daily Logs/';
  json(res, walk('06 - Daily Logs', '.md', 0, A).map(f => ({
    ...f, path: prefix + f.name
  })));
}));

app.get('/api/daily-log/:date', safe((req, res) => {
  const r = render(`06 - Daily Logs/${req.params.date}.md`, A);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.post('/api/daily-log', safe((req, res) => {
  const { date, content } = req.body;
  if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) return err(res, 'Invalid date format (YYYY-MM-DD)');
  write(`06 - Daily Logs/${date}.md`, content || `# ${date}\n\n## What I did\n\n## What I learned\n\n## Tomorrow\n`, A);
  json(res, { ok: true });
}));

app.put('/api/daily-log/:date', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  const rel = `06 - Daily Logs/${req.params.date}.md`;
  backup(rel, A);
  write(rel, req.body.content, A);
  json(res, { ok: true });
}));

app.delete('/api/daily-log/:date', safe((req, res) => {
  const rel = `06 - Daily Logs/${req.params.date}.md`;
  backup(rel, A);
  remove(rel, A) ? json(res, { ok: true }) : err(res, 'Not found', 404);
}));

// ── Conversation Capture (merged from AI-OS Dashboard) ────────────────
app.post('/api/conversations', safe((req, res) => {
  const { tool, domain, question, answer } = req.body;
  if (!question || !tool) return err(res, 'Tool and question required');
  const d = new Date().toISOString().slice(0, 10);
  const t = new Date().toTimeString().slice(0, 5);
  const safeQ = sanitize(String(question)).replace(/[\\/:*?"<>|]/g, '_').replace(/\s+/g, '_').slice(0, 50);
  const fn = `${d}_${String(tool).toLowerCase()}_${safeQ}.md`;
  const rel = `04 - AI Conversations/${fn}`;
  write(rel, [
    '---',
    `aliases: [auto-${String(tool).toLowerCase()}]`,
    'tags: [auto-captured, ai-conversation, ' + String(domain || 'general').toLowerCase() + ']',
    `tool: ${tool}`,
    `domain: ${domain || ''}`,
    `date: ${d}`,
    `time: ${t}`,
    '---',
    '',
    `# AI Conversation: ${question}`,
    '',
    `**Tool:** ${tool}`,
    `**Domain:** ${domain || 'TBD'}`,
    `**Date:** ${d} ${t}`,
    '',
    '---',
    '',
    '## Question/Topic',
    '',
    question,
    '',
    '## Response',
    '',
    answer || '',
    '',
    '## Key Takeaways',
    '',
    '- [ ] ',
    '- [ ] ',
    '- [ ] ',
    '',
    '---',
    '*Captured via Cyber-Hub*'
  ].join('\n'), A);
  json(res, { ok: true, path: rel });
}));

// ── Learning Session (merged from AI-OS Dashboard) ────────────────────
app.post('/api/learning-session', safe((req, res) => {
  const { domain, focus, duration, didWhat, progressUpdate, levelUpdate } = req.body;
  if (!domain || !focus) return err(res, 'Domain and focus required');
  const d = new Date().toISOString().slice(0, 10);
  const t = new Date().toTimeString().slice(0, 5);
  const safeFocus = sanitize(String(focus)).replace(/[\\/:*?"<>|]/g, '_').replace(/\s+/g, '_').slice(0, 30);
  const safeDomain = sanitize(String(domain)).replace(/[\\/:*?"<>|]/g, '_').replace(/\s+/g, '_');
  const fn = `${d}_session_${safeDomain}_${safeFocus}.md`;
  const rel = `06 - Daily Logs/${fn}`;
  write(rel, [
    '---',
    'aliases: [session-' + String(focus).toLowerCase().replace(/\s+/g, '-') + ']',
    'tags: [learning, session, ' + String(domain).toLowerCase().replace(/\s+/g, '') + ']',
    `date: ${d}`,
    `time: ${t}`,
    '---',
    '',
    `# 📚 Learning Session: ${focus}`,
    '',
    '## 📋 Session Info',
    '',
    `**Date:** ${d}`,
    `**Time:** ${t}`,
    `**Domain:** ${domain}`,
    `**Focus Area:** ${focus}`,
    `**Duration:** ${duration || ''}`,
    '',
    '---',
    '',
    '## 🎯 Learning Objectives',
    '',
    '- [x] Practice and implement ' + focus,
    '- [ ] Document key concepts and takeaways',
    '',
    '## 📚 What I Learned & Did',
    '',
    '1. **Applied Practice:** ' + (didWhat || ''),
    '',
    '## 💻 Practice Done',
    '',
    '- Hands-on implementation of ' + focus + '.',
    '- Tested code and verified outputs.',
    '',
    '---',
    '*Logged via Cyber-Hub*'
  ].join('\n'), A);
  if (progressUpdate !== undefined || levelUpdate !== undefined) {
    const rawDom = String(domain).trim();
    const skillRel = `02 - Skills/${rawDom}.md`;
    const skillRelSlug = `02 - Skills/${safeDomain}.md`;
    const c = read(skillRel, A) || read(skillRelSlug, A);
    const usedRel = read(skillRel, A) ? skillRel : skillRelSlug;
    if (c && usedRel) {
      backup(usedRel, A);
      let updated = c;
      if (levelUpdate !== undefined) {
        updated = updated.replace(/mastery_level:\s*\S+/, `mastery_level: ${Math.min(6, Math.max(1, parseInt(levelUpdate) || 1))}`);
      }
      if (progressUpdate !== undefined) {
        updated = updated.replace(/progress:\s*\S+/, `progress: ${Math.min(100, Math.max(0, parseInt(progressUpdate) || 0))}`);
      }
      updated = updated.replace(/status:\s*[^\n]*/, `status: ${parseInt(progressUpdate || 0) >= 100 ? 'Completed' : 'In Progress'}`);
      write(usedRel, updated, A);
    }
  }
  json(res, { ok: true, path: rel });
}));

// ── Skills ─────────────────────────────────────────────────────────────
app.get('/api/skills', safe((_, res) => {
  json(res, walk('02 - Skills', '.md', 0, A).map(f => {
    const { meta, body } = fm(read(path.join('02 - Skills', f.name), A) || '');
    return { ...f, meta, body: body.slice(0, 500) };
  }));
}));

app.get('/api/skill/:name', safe((req, res) => {
  const r = render(`02 - Skills/${req.params.name}.md`, A);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/skill/:name', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  const rel = `02 - Skills/${req.params.name}.md`;
  backup(rel, A);
  write(rel, req.body.content, A);
  json(res, { ok: true });
}));

app.put('/api/skill/:name/mastery', safe((req, res) => {
  const { level, progress, status } = req.body;
  const rel = `02 - Skills/${req.params.name}.md`;
  const c = read(rel, A); if (!c) return err(res, 'Not found', 404);
  backup(rel, A);
  let updated = c;
  if (level !== undefined) {
    updated = updated.replace(/mastery_level:\s*\S+/, `mastery_level: ${Math.min(6, Math.max(1, parseInt(level) || 1))}`);
  }
  if (progress !== undefined) {
    updated = updated.replace(/progress:\s*\S+/, `progress: ${Math.min(100, Math.max(0, parseInt(progress) || 0))}`);
  }
  if (status !== undefined) {
    updated = updated.replace(/status:\s*[^\n]*/, `status: ${sanitize(status)}`);
  }
  write(rel, updated, A);
  json(res, { ok: true });
}));

// ── Sync files ─────────────────────────────────────────────────────────
app.get('/api/persistent-memory', safe((_, res) => {
  const r = render('08 - Cross-Tool Sync/PERSISTENT_MEMORY.md');
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/persistent-memory', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  backup('08 - Cross-Tool Sync/PERSISTENT_MEMORY.md');
  write('08 - Cross-Tool Sync/PERSISTENT_MEMORY.md', req.body.content);
  json(res, { ok: true });
}));

app.get('/api/latest-context', safe((_, res) => {
  const r = render('08 - Cross-Tool Sync/LATEST_CONTEXT.md');
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/latest-context', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  backup('08 - Cross-Tool Sync/LATEST_CONTEXT.md');
  write('08 - Cross-Tool Sync/LATEST_CONTEXT.md', req.body.content);
  json(res, { ok: true });
}));

// ── Tool Notes ─────────────────────────────────────────────────────────
app.get('/api/tool-notes', safe((_, res) => json(res, walk('06 - Tool Notes'))));

app.get('/api/tool-note/:name', safe((req, res) => {
  const r = render(`06 - Tool Notes/${req.params.name}.md`);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/tool-note/:name', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  const rel = `06 - Tool Notes/${req.params.name}.md`;
  backup(rel); write(rel, req.body.content);
  json(res, { ok: true });
}));

app.delete('/api/tool-note/:name', safe((req, res) => {
  const rel = `06 - Tool Notes/${req.params.name}.md`;
  backup(rel);
  remove(rel) ? json(res, { ok: true }) : err(res, 'Not found', 404);
}));

// ── Learning Paths ─────────────────────────────────────────────────────
app.get('/api/learning-paths', safe((_, res) => {
  json(res, walk('01 - Learning Paths', '.md', 0, A));
}));

app.get('/api/learning-path/:name', safe((req, res) => {
  const r = render(`01 - Learning Paths/${req.params.name}.md`, A);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

// ── Conversations ──────────────────────────────────────────────────────
app.get('/api/conversations', safe((_, res) => {
  json(res, walk('04 - AI Conversations', '.md', 0, A));
}));

// ── Configs ────────────────────────────────────────────────────────────
app.get('/api/configs', safe((_, res) => {
  json(res, walk('01 - Configs & Settings', '.md', 0, H));
}));

// ── Vault tree ─────────────────────────────────────────────────────────
app.get('/api/vault-tree', safe((req, res) => {
  const vkey = req.query.vault === 'ai-os' ? 'ai-os' : 'history';
  const vault = VAULTS[vkey];
  const tree = (dir, depth = 0) => {
    if (!exists(dir) || depth > 3) return [];
    let entries;
    try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return []; }
    return entries.filter(d => !d.name.startsWith('.')).map(d => {
      const fp = path.join(dir, d.name);
      try {
        const entry = { name: d.name, isDir: d.isDirectory() };
        if (d.isDirectory()) entry.children = tree(fp, depth + 1);
        else { const s = fs.statSync(fp); entry.size = s.size; entry.modified = s.mtime.toISOString(); }
        return entry;
      } catch { return null; }
    }).filter(Boolean);
  };
  json(res, tree(vault));
}));

// ── Backups ────────────────────────────────────────────────────────────
app.get('/api/backups', safe((req, res) => {
  const vkey = req.query.vault === 'ai-os' ? 'ai-os' : 'history';
  const dir = vkey === 'ai-os' ? BACKUP_DIR_A : BACKUP_DIR_H;
  if (!exists(dir)) return json(res, []);
  json(res, fs.readdirSync(dir).filter(f => f.endsWith('.md')).map(f => {
    try {
      const s = fs.statSync(path.join(dir, f));
      return { name: f, size: s.size, modified: s.mtime.toISOString(), vault: vkey };
    } catch { return null; }
  }).filter(Boolean).sort((a, b) => b.modified.localeCompare(a.modified)).slice(0, 100));
}));

app.get('/api/backup/:name', safe((req, res) => {
  const dir = exists(path.join(BACKUP_DIR_H, req.params.name)) ? BACKUP_DIR_H : BACKUP_DIR_A;
  const f = path.join(dir, req.params.name);
  if (!exists(f)) return err(res, 'Not found', 404);
  const c = fs.readFileSync(f, 'utf-8');
  json(res, { raw: c, html: marked(c) });
}));

// ── Timeline ───────────────────────────────────────────────────────────
app.get('/api/timeline', safe((req, res) => {
  const limit = parseInt(req.query.limit) || 50;
  const all = [];
  const scan = (dir, vault, vaultKey) => {
    if (!exists(dir)) return;
    const walkFn = (d) => {
      let entries;
      try { entries = fs.readdirSync(d, { withFileTypes: true }); } catch { return; }
      for (const ent of entries) {
        if (ent.name.startsWith('.')) continue;
        const fp = path.join(d, ent.name);
        try {
          if (ent.isDirectory()) { walkFn(fp); continue; }
          if (!ent.name.endsWith('.md')) continue;
          const s = fs.statSync(fp);
          const content = fs.readFileSync(fp, 'utf-8');
          const { meta, body } = fm(content);
          all.push({
            name: ent.name, path: path.relative(vault, fp).replace(/\\/g, '/'),
            vault: vaultKey, modified: s.mtime.toISOString(), size: s.size,
            title: meta.title || ent.name.replace('.md', ''),
            tags: meta.tags || [], date: meta.date || s.mtime.toISOString().slice(0, 10)
          });
        } catch { continue; }
      }
    };
    walkFn(dir);
  };
  scan(path.join(H, '02 - Session History'), H, 'history');
  scan(path.join(A, '06 - Daily Logs'), A, 'ai-os');
  scan(path.join(H, '03 - Projects'), H, 'history');
  scan(path.join(A, '02 - Skills'), A, 'ai-os');
  json(res, all.sort((a, b) => b.modified.localeCompare(a.modified)).slice(0, limit));
}));

// ── Recent activity ────────────────────────────────────────────────────
app.get('/api/recent', safe((req, res) => {
  const limit = parseInt(req.query.limit) || 20;
  const all = [];
  const scan = (dir, vault, prefix) => {
    if (!exists(dir)) return;
    const walkFn = (d) => {
      let entries;
      try { entries = fs.readdirSync(d, { withFileTypes: true }); } catch { return; }
      for (const ent of entries) {
        if (ent.name.startsWith('.')) continue;
        const fp = path.join(d, ent.name);
        try {
          if (ent.isDirectory()) { walkFn(fp); continue; }
          if (!ent.name.endsWith('.md')) continue;
          const s = fs.statSync(fp);
          all.push({ name: ent.name, path: path.relative(vault, fp).replace(/\\/g, '/'), vault: prefix, modified: s.mtime.toISOString(), size: s.size });
        } catch { continue; }
      }
    };
    walkFn(dir);
  };
  scan(H, H, 'history'); scan(A, A, 'ai-os');
  json(res, all.sort((a, b) => b.modified.localeCompare(a.modified)).slice(0, limit));
}));

// ── Generic file CRUD ──────────────────────────────────────────────────
app.get('/api/file/*', safe((req, res) => {
  const v = vaultFor(req.query.vault);
  if (!safePath(req.params[0], v)) return err(res, 'Invalid path', 403);
  const r = render(req.params[0], v);
  r ? json(res, r) : err(res, 'Not found', 404);
}));

app.put('/api/file/*', safe((req, res) => {
  if (!req.body.content) return err(res, 'Content required');
  const v = vaultFor(req.body.vault);
  if (!safePath(req.params[0], v)) return err(res, 'Invalid path', 403);
  backup(req.params[0], v);
  write(req.params[0], req.body.content, v);
  json(res, { ok: true });
}));

app.post('/api/file', safe((req, res) => {
  const { path: fp, content, vault } = req.body;
  if (!fp || !content) return err(res, 'Path and content required');
  const v = vaultFor(vault);
  if (!safePath(fp, v)) return err(res, 'Invalid path', 403);
  write(fp, content, v);
  json(res, { ok: true });
}));

app.delete('/api/file/*', safe((req, res) => {
  const v = vaultFor(req.query.vault);
  if (!safePath(req.params[0], v)) return err(res, 'Invalid path', 403);
  backup(req.params[0], v);
  remove(req.params[0], v) ? json(res, { ok: true }) : err(res, 'Not found', 404);
}));

// ── Search ─────────────────────────────────────────────────────────────
app.get('/api/search', safe((req, res) => {
  const q = (req.query.q || '').trim();
  if (!q || q.length < 2) return json(res, []);
  const ql = q.toLowerCase();
  const results = [];
  const searchDir = (dir, vault, vaultKey) => {
    if (!exists(dir)) return;
    const walkFn = (d) => {
      let entries;
      try { entries = fs.readdirSync(d, { withFileTypes: true }); } catch { return; }
      for (const ent of entries) {
        if (ent.name.startsWith('.')) continue;
        const fp = path.join(d, ent.name);
        try {
          if (ent.isDirectory()) { walkFn(fp); continue; }
          if (!ent.name.endsWith('.md')) continue;
          const c = fs.readFileSync(fp, 'utf-8');
          const cl = c.toLowerCase();
          if (cl.includes(ql)) {
            const i = cl.indexOf(ql);
            const start = Math.max(0, i - 50);
            const end = Math.min(c.length, i + q.length + 50);
            let snippet = c.slice(start, end).replace(/\n/g, ' ').trim();
            if (start > 0) snippet = '...' + snippet;
            if (end < c.length) snippet = snippet + '...';
            results.push({
              path: path.relative(vault, fp).replace(/\\/g, '/'),
              name: ent.name, snippet, vault: vaultKey,
              score: (cl.match(new RegExp(ql.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g')) || []).length
            });
          }
        } catch { continue; }
      }
    };
    walkFn(dir);
  };
  searchDir(H, H, 'history'); searchDir(A, A, 'ai-os');
  json(res, results.sort((a, b) => b.score - a.score).slice(0, 50));
}));

// ── Scratch pad ────────────────────────────────────────────────────────
app.get('/api/scratch', safe((_, res) => {
  json(res, { raw: exists(SCRATCH) ? fs.readFileSync(SCRATCH, 'utf-8') : '# Scratch Pad\n\nQuick notes that auto-save here.\n' });
}));

app.put('/api/scratch', safe((req, res) => {
  fs.mkdirSync(path.dirname(SCRATCH), { recursive: true });
  fs.writeFileSync(SCRATCH, req.body.content || '', 'utf-8');
  json(res, { ok: true });
}));

// ── Batch operations ───────────────────────────────────────────────────
app.post('/api/batch', safe((req, res) => {
  const { operations } = req.body;
  if (!Array.isArray(operations)) return err(res, 'Operations array required');
  const results = [];
  for (const op of operations.slice(0, 10)) {
    try {
      const v = vaultFor(op.vault);
      if (op.action === 'read') {
        const c = read(op.path, v);
        results.push({ path: op.path, ok: !!c, content: c });
      } else if (op.action === 'write') {
        write(op.path, op.content, v);
        results.push({ path: op.path, ok: true });
      } else if (op.action === 'delete') {
        backup(op.path, v);
        results.push({ path: op.path, ok: remove(op.path, v) });
      } else {
        results.push({ path: op.path, ok: false, error: 'Unknown action' });
      }
    } catch (e) {
      results.push({ path: op.path, ok: false, error: e.message });
    }
  }
  json(res, { results });
}));

// ── Fallback ───────────────────────────────────────────────────────────
app.get('*', (_, res) => res.sendFile(path.join(__dirname, 'public', 'index.html')));

// ── Start ──────────────────────────────────────────────────────────────
const server = app.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log('  \x1b[36m╔══════════════════════════════════════╗\x1b[0m');
  console.log('  \x1b[36m║\x1b[0m  \x1b[1mCYBER-HUB\x1b[0m // AI Vault Command Center');
  console.log('  \x1b[36m║\x1b[0m  \x1b[90mhttp://localhost:' + PORT + '\x1b[0m');
  console.log('  \x1b[36m║\x1b[0m  Vaults: ' + (exists(H) ? '\x1b[32m✓\x1b[0m History' : '\x1b[31m✗\x1b[0m History') + ' | ' + (exists(A) ? '\x1b[32m✓\x1b[0m AI-OS' : '\x1b[31m✗\x1b[0m AI-OS'));
  console.log('  \x1b[36m╚══════════════════════════════════════╝\x1b[0m');
  console.log('');
});

// ── Graceful shutdown ──────────────────────────────────────────────────
const shutdown = (sig) => {
  console.log(`\n  \x1b[90m${sig} received. Shutting down...\x1b[0m`);
  server.close(() => { process.exit(0); });
  setTimeout(() => process.exit(1), 3000);
};
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
