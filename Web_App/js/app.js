// === App State ===
const App = {
    currentTab: 'dashboard',
    selectedDate: new Date(),
    displayedMonth: new Date(),
    calendarExpanded: true,
    dashboardRange: 'week',
    theme: 'system',
    workStartHour: 9,
    workEndHour: 19,
    filterNoTitle: true,
    visits: [], // { id, clientName, serviceNote, startDate, endDate }
    nextId: 1
};

// === Init ===
function init() {
    loadState();
    applyTheme();
    render();
    window.addEventListener('resize', () => { applyTheme(); });
}

// === Persistence ===
function loadState() {
    try {
        const saved = JSON.parse(localStorage.getItem('pediglam_state') || '{}');
        if (saved.visits) { App.visits = saved.visits; App.nextId = saved.nextId || 1; }
        if (saved.workStartHour) App.workStartHour = saved.workStartHour;
        if (saved.workEndHour) App.workEndHour = saved.workEndHour;
        if (saved.filterNoTitle !== undefined) App.filterNoTitle = saved.filterNoTitle;
        if (saved.theme) App.theme = saved.theme;
        if (saved.dashboardRange) App.dashboardRange = saved.dashboardRange;
    } catch(e) {}
}

function saveState() {
    localStorage.setItem('pediglam_state', JSON.stringify({
        visits: App.visits,
        nextId: App.nextId,
        workStartHour: App.workStartHour,
        workEndHour: App.workEndHour,
        filterNoTitle: App.filterNoTitle,
        theme: App.theme,
        dashboardRange: App.dashboardRange
    }));
}

// === Theme ===
function applyTheme() {
    const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    if (App.theme === 'dark') document.documentElement.setAttribute('data-theme', 'dark');
    else if (App.theme === 'light') document.documentElement.setAttribute('data-theme', 'light');
    else document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
}

function setTheme(t) { App.theme = t; applyTheme(); saveState(); }

// === Navigation ===
function switchTab(tab) {
    App.currentTab = tab;
    render();
}

// === Date Helpers ===
function fmtTime(d) { return `${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`; }
function fmtDate(d) { return d.toLocaleDateString('en-US', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }); }
function fmtShortDate(d) { return d.toLocaleDateString('en-US', { day: 'numeric', month: 'short' }); }
function fmtMonthYear(d) { return d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }); }
function fmtDuration(min) {
    if (min < 60) return `${min} min`;
    const h = Math.floor(min / 60), m = min % 60;
    return m === 0 ? `${h}h` : `${h}h ${m}min`;
}
function startOfDay(d) { const nd = new Date(d); nd.setHours(0,0,0,0); return nd; }
function daysInMonth(d) { return new Date(d.getFullYear(), d.getMonth()+1, 0).getDate(); }
function firstWeekday(d) { const fd = new Date(d.getFullYear(), d.getMonth(), 1); const wd = fd.getDay(); return wd === 0 ? 6 : wd - 1; }
function isSameDay(a, b) { return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate(); }
function isToday(d) { return isSameDay(d, new Date()); }

// === Visit CRUD ===
function addVisit(clientName, serviceNote, startDate, endDate) {
    const id = App.nextId++;
    App.visits.push({ id, clientName, serviceNote: serviceNote || '', startDate: startDate.toISOString(), endDate: endDate.toISOString() });
    saveState();
    return id;
}

function getVisitsForDate(date) {
    const dayStart = startOfDay(date);
    const dayEnd = new Date(dayStart); dayEnd.setDate(dayEnd.getDate()+1);
    return App.visits.filter(v => {
        const s = new Date(v.startDate), e = new Date(v.endDate);
        return s < dayEnd && e > dayStart;
    }).sort((a,b) => new Date(a.startDate) - new Date(b.startDate));
}

function getVisitsInRange(start, end) {
    return App.visits.filter(v => {
        const s = new Date(v.startDate), e = new Date(v.endDate);
        return s < end && e > start;
    });
}

function getVisitById(id) {
    return App.visits.find(v => v.id === id);
}

function conflictingEvents(start, end) {
    return App.visits.filter(v => {
        const s = new Date(v.startDate), e = new Date(v.endDate);
        return s < end && e > start;
    });
}

// === Slot Calculation (same logic as iOS) ===
function calculateSlots(date) {
    const dayStart = startOfDay(date);
    const ws = new Date(dayStart); ws.setHours(App.workStartHour, 0, 0, 0);
    const we = new Date(dayStart); we.setHours(App.workEndHour, 0, 0, 0);
    const events = getVisitsForDate(date).map(v => ({ ...v, startDate: new Date(v.startDate), endDate: new Date(v.endDate) }));
    
    // Clamp to working hours
    const busy = events
        .filter(e => e.startDate < we && e.endDate > ws)
        .map(e => ({ start: new Date(Math.max(e.startDate, ws)), end: new Date(Math.min(e.endDate, we)), clientName: e.clientName, serviceNote: e.serviceNote }))
        .sort((a,b) => a.start - b.start);
    
    // Merge overlaps
    const merged = [];
    for (const b of busy) {
        const last = merged[merged.length-1];
        if (last && b.start <= last.end) {
            last.end = new Date(Math.max(last.end, b.end));
            last.clientName += ', ' + b.clientName;
        } else {
            merged.push({ ...b });
        }
    }
    
    // Build slots with free gaps
    const slots = [];
    let ptr = new Date(ws);
    for (const b of merged) {
        if (ptr < b.start) {
            slots.push({ type: 'free', start: new Date(ptr), end: new Date(b.start) });
        }
        slots.push({ type: 'busy', start: new Date(b.start), end: new Date(b.end), clientName: b.clientName, serviceNote: b.serviceNote });
        ptr = new Date(b.end);
    }
    if (ptr < we) {
        slots.push({ type: 'free', start: new Date(ptr), end: new Date(we) });
    }
    return slots;
}

// === Dashboard Stats ===
function getDashboardStats() {
    const now = new Date();
    let rangeStart, rangeEnd;
    switch(App.dashboardRange) {
        case 'day':
            rangeStart = startOfDay(now);
            rangeEnd = new Date(rangeStart); rangeEnd.setDate(rangeEnd.getDate()+1);
            break;
        case 'week': {
            const dow = now.getDay(); const monOffset = dow === 0 ? 6 : dow - 1;
            rangeStart = startOfDay(now); rangeStart.setDate(rangeStart.getDate() - monOffset);
            rangeEnd = new Date(rangeStart); rangeEnd.setDate(rangeEnd.getDate()+7);
            break;
        }
        case 'month':
            rangeStart = new Date(now.getFullYear(), now.getMonth(), 1);
            rangeEnd = new Date(now.getFullYear(), now.getMonth()+1, 1);
            break;
        case 'year':
            rangeStart = new Date(now.getFullYear(), 0, 1);
            rangeEnd = new Date(now.getFullYear()+1, 0, 1);
            break;
    }
    
    const events = getVisitsInRange(rangeStart, rangeEnd);
    const clients = new Set(events.map(e => e.clientName));
    const days = Math.ceil((rangeEnd - rangeStart) / (1000*60*60*24));
    const workMinPerDay = (App.workEndHour - App.workStartHour) * 60;
    const totalWorkMin = days * workMinPerDay;
    
    let busyMin = 0;
    for (const e of events) {
        const s = new Date(Math.max(new Date(e.startDate), rangeStart));
        const end = new Date(Math.min(new Date(e.endDate), rangeEnd));
        if (end > s) busyMin += (end - s) / 60000;
    }
    const freeMin = Math.max(0, totalWorkMin - Math.round(busyMin));
    
    return {
        totalVisits: events.length,
        uniqueClients: clients.size,
        busyMin: Math.round(busyMin),
        freeMin,
        occupancyRate: totalWorkMin > 0 ? Math.round(busyMin) / totalWorkMin : 0,
        rangeLabel: `${fmtShortDate(rangeStart)} – ${fmtShortDate(new Date(rangeEnd.getTime()-1000))}`,
        recentVisits: events.sort((a,b) => new Date(b.startDate) - new Date(a.startDate)).slice(0, 10)
    };
}

// === Render ===
function render() {
    const app = document.getElementById('app');
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    const t = App.currentTab;
    
    const tabIcons = {
        dashboard: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>`,
        day: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>`,
        calendar: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>`,
        settings: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>`
    };
    
    app.innerHTML = `
        <div class="top-bar">
            <h1>${t === 'dashboard' ? 'Dashboard' : t === 'calendar' ? 'Select Date' : t === 'settings' ? 'Settings' : 'Day'}</h1>
            <div class="spacer"></div>
            ${t === 'day' || t === 'calendar' ? `<button class="btn-icon large" onclick="showCreateVisit()" title="New Visit">+</button>` : ''}
        </div>
        <div class="content" id="content-area">
            ${renderContent(t)}
        </div>
        <div class="tab-bar">
            ${['dashboard','day','calendar','settings'].map(tab => `
                <button class="tab-btn ${t === tab ? 'active' : ''}" onclick="switchTab('${tab}')">
                    ${tabIcons[tab]}
                    ${tab.charAt(0).toUpperCase()+tab.slice(1)}
                </button>
            `).join('')}
        </div>
    `;
}

function renderContent(t) {
    switch(t) {
        case 'dashboard': return renderDashboard();
        case 'day': return renderDay();
        case 'calendar': return renderCalendar();
        case 'settings': return renderSettings();
        default: return '';
    }
}

// === Dashboard ===
function renderDashboard() {
    const stats = getDashboardStats();
    const ranges = ['day','week','month','year'];
    
    return `
        <div class="filter-pills">
            ${ranges.map(r => `
                <button class="filter-pill ${App.dashboardRange === r ? 'active' : ''}" onclick="setDashboardRange('${r}')">${r.charAt(0).toUpperCase()+r.slice(1)}</button>
            `).join('')}
        </div>
        <div class="text-secondary" style="font-size:12px; margin-bottom:8px">${stats.rangeLabel}</div>
        
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-icon text-blue">👥</div>
                <div class="stat-label">Visits</div>
                <div class="stat-value">${stats.totalVisits}</div>
                <div class="stat-sub">${stats.uniqueClients} clients</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="color:var(--red)">⏱</div>
                <div class="stat-label">Busy</div>
                <div class="stat-value">${fmtDuration(stats.busyMin)}</div>
                <div class="stat-sub">scheduled</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="color:var(--green)">✓</div>
                <div class="stat-label">Free</div>
                <div class="stat-value">${fmtDuration(stats.freeMin)}</div>
                <div class="stat-sub">available</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">📊</div>
                <div class="stat-label">Occupancy</div>
                <div class="stat-value">${Math.round(stats.occupancyRate*100)}%</div>
                <div class="stat-sub">fill rate</div>
            </div>
        </div>
        
        ${stats.recentVisits.length > 0 ? `
            <div class="section-title mt-8">Recent visits</div>
            ${stats.recentVisits.map(v => {
                const sd = new Date(v.startDate), ed = new Date(v.endDate);
                const dur = Math.round((ed-sd)/60000);
                return `
                    <div class="visit-row" onclick="showVisitDetail(${v.id})">
                        <div class="visit-avatar blue">${v.clientName.charAt(0).toUpperCase()}</div>
                        <div class="visit-info">
                            <div class="visit-name">${esc(v.clientName)}</div>
                            ${v.serviceNote ? `<div class="visit-service">${esc(v.serviceNote)}</div>` : ''}
                        </div>
                        <div class="visit-meta">
                            <div class="visit-time">${fmtTime(sd)}</div>
                            <div class="visit-date">${fmtShortDate(sd)}</div>
                            <div class="visit-duration">${fmtDuration(dur)}</div>
                        </div>
                        <span class="visit-chevron">›</span>
                    </div>
                `;
            }).join('')}
        ` : `
            <div class="empty-state">
                <div class="empty-icon">📋</div>
                <div class="empty-text">No visits found</div>
                <div class="empty-sub">No appointments in this ${App.dashboardRange} range</div>
            </div>
        `}
    `;
}

function setDashboardRange(r) {
    App.dashboardRange = r;
    saveState();
    render();
}

function showVisitDetail(id) {
    const v = getVisitById(id);
    if (!v) return;
    const sd = new Date(v.startDate), ed = new Date(v.endDate);
    const dur = Math.round((ed-sd)/60000);
    showModal(`
        <h2>${esc(v.clientName)}</h2>
        <div style="display:flex;flex-direction:column;gap:10px;font-size:14px;">
            <div><strong>Date:</strong> ${fmtDate(sd)}</div>
            <div><strong>Time:</strong> ${fmtTime(sd)} – ${fmtTime(ed)}</div>
            <div><strong>Duration:</strong> ${fmtDuration(dur)}</div>
            ${v.serviceNote ? `<div><strong>Service:</strong> ${esc(v.serviceNote)}</div>` : ''}
        </div>
        <button class="btn-primary mt-8" onclick="closeModal()">Close</button>
    `);
}

// === Day View ===
function renderDay() {
    const slots = calculateSlots(App.selectedDate);
    const startStr = `${String(App.workStartHour).padStart(2,'0')}:00`;
    const endStr = `${String(App.workEndHour).padStart(2,'0')}:00`;
    
    let html = `
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
            <div>
                <div style="font-size:17px;font-weight:600">${fmtDate(App.selectedDate)}</div>
                <div style="font-size:12px;color:var(--text-secondary)">Working hours: ${startStr} – ${endStr}</div>
            </div>
            <input type="date" value="${toDateInput(App.selectedDate)}" onchange="selectDate(this.value)" style="font-size:13px;padding:4px 8px;border-radius:8px;border:none;background:var(--card);color:var(--text);box-shadow:var(--shadow)">
        </div>
        <div class="divider"></div>
    `;
    
    if (slots.length === 0) {
        html += `
            <div class="empty-state">
                <div class="empty-icon">✨</div>
                <div class="empty-text">No appointments this day</div>
            </div>
        `;
    } else {
        html += slots.map(s => {
            const dur = Math.round((s.end - s.start) / 60000);
            if (s.type === 'free') {
                return `
                    <div class="slot-card">
                        <div class="slot-accent green"></div>
                        <div class="slot-icon green">🕐</div>
                        <div class="slot-content">
                            <div style="font-size:13px;color:var(--green);font-weight:600;margin-bottom:2px">FREE ${fmtTime(s.start)} – ${fmtTime(s.end)}</div>
                            <div class="slot-title">${fmtDuration(dur)} free</div>
                        </div>
                    </div>
                `;
            } else {
                return `
                    <div class="slot-card">
                        <div class="slot-accent red"></div>
                        <div class="slot-icon red">${s.clientName.charAt(0).toUpperCase()}</div>
                        <div class="slot-content">
                            <div class="slot-title">${esc(s.clientName)}</div>
                            ${s.serviceNote ? `<div class="slot-sub">${esc(s.serviceNote)}</div>` : ''}
                            <div class="slot-sub">${fmtDuration(dur)}</div>
                        </div>
                        <div class="slot-time">${fmtTime(s.start)} – ${fmtTime(s.end)}</div>
                    </div>
                `;
            }
        }).join('');
        
        // Summary
        const busyMin = slots.filter(s=>s.type==='busy').reduce((a,s)=>a+Math.round((s.end-s.start)/60000),0);
        const freeMin = slots.filter(s=>s.type==='free').reduce((a,s)=>a+Math.round((s.end-s.start)/60000),0);
        const total = busyMin + freeMin;
        const occ = total > 0 ? Math.round(busyMin/total*100) : 0;
        
        html += `
            <div class="divider"></div>
            <div class="summary-row">
                <span class="summary-icon">📊</span>
                <span class="summary-title">Day Summary</span>
                <div class="summary-bar">
                    <div class="summary-bar-fill" style="width:${occ}%;background:var(--red)"></div>
                    <div class="summary-bar-fill" style="width:${100-occ}%;background:var(--green);margin-top:-4px"></div>
                </div>
                <div class="summary-stats">
                    <span style="color:var(--green)">${fmtDuration(freeMin)}</span>
                    <span>${occ}%</span>
                    <span style="color:var(--red)">${fmtDuration(busyMin)}</span>
                </div>
            </div>
        `;
    }
    
    return html;
}

function selectDate(val) {
    App.selectedDate = new Date(val + 'T00:00:00');
    render();
}

function toDateInput(d) {
    return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

// === Calendar View ===
function renderCalendar() {
    const dm = App.displayedMonth;
    const year = dm.getFullYear(), month = dm.getMonth();
    const days = daysInMonth(dm);
    const startDow = firstWeekday(dm);
    const today = new Date();
    
    let html = '';
    
    if (App.calendarExpanded) {
        // Full calendar
        html += `
            <div class="calendar-card">
                <div class="month-nav">
                    <button onclick="shiftMonth(-1)">‹</button>
                    <div class="month-label" onclick="toggleCalendar()">${fmtMonthYear(dm)} ⌃</div>
                    <button onclick="shiftMonth(1)">›</button>
                </div>
                <div class="today-row">
                    <button class="btn-today ${isToday(App.selectedDate) ? 'active' : ''}" onclick="goToday()">Today</button>
                    <span class="text-secondary">${fmtDate(App.selectedDate)}</span>
                </div>
                <div class="day-headers">
                    ${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map(d => `<span>${d}</span>`).join('')}
                </div>
                <div class="calendar-grid">
                    ${(() => {
                        let cells = '';
                        for (let i = 0; i < startDow; i++) cells += '<div></div>';
                        for (let d = 1; d <= days; d++) {
                            const date = new Date(year, month, d);
                            const sel = isSameDay(date, App.selectedDate);
                            const tdy = isToday(date);
                            const hasEvents = getVisitsForDate(date).length > 0;
                            cells += `<button class="calendar-cell${!isSameDay(date, dm) ? ' other-month' : ''}${tdy ? ' today' : ''}${sel ? ' selected' : ''}" onclick="pickCalendarDate(${year},${month},${d})">${d}${hasEvents && !sel ? '<span class="dot"></span>' : ''}</button>`;
                        }
                        return cells;
                    })()}
                </div>
            </div>
        `;
    } else {
        // Compact header
        html += `
            <div class="compact-header" onclick="toggleCalendar()">
                <span class="month-label">${fmtMonthYear(dm)}</span>
                <span class="chevron">⌄</span>
                <span class="spacer"></span>
                <button class="btn-today ${isToday(App.selectedDate) ? 'active' : ''}" onclick="event.stopPropagation();goToday()">Today</button>
                <span class="text-secondary" style="font-size:12px">${fmtDate(App.selectedDate)}</span>
            </div>
        `;
    }
    
    // Slots for selected day
    const slots = calculateSlots(App.selectedDate);
    if (slots.length === 0) {
        html += `
            <div class="empty-state">
                <div class="empty-icon">✨</div>
                <div class="empty-text">No appointments this day</div>
            </div>
        `;
    } else {
        html += slots.map(s => {
            const dur = Math.round((s.end - s.start) / 60000);
            if (s.type === 'free') {
                return `
                    <div class="slot-card">
                        <div class="slot-accent green"></div>
                        <div class="slot-icon green">🕐</div>
                        <div class="slot-content">
                            <div style="font-size:12px;color:var(--green);font-weight:600">FREE ${fmtTime(s.start)} – ${fmtTime(s.end)}</div>
                            <div class="slot-title">${fmtDuration(dur)} free</div>
                        </div>
                    </div>
                `;
            }
            return `
                <div class="slot-card">
                    <div class="slot-accent red"></div>
                    <div class="slot-icon red">${s.clientName.charAt(0).toUpperCase()}</div>
                    <div class="slot-content">
                        <div class="slot-title">${esc(s.clientName)}</div>
                        ${s.serviceNote ? `<div class="slot-sub">${esc(s.serviceNote)}</div>` : ''}
                        <div class="slot-sub">${fmtDuration(dur)}</div>
                    </div>
                    <div class="slot-time">${fmtTime(s.start)} – ${fmtTime(s.end)}</div>
                </div>
            `;
        }).join('');
    }
    
    return html;
}

function shiftMonth(delta) {
    App.displayedMonth.setMonth(App.displayedMonth.getMonth() + delta);
    render();
}

function toggleCalendar() {
    App.calendarExpanded = !App.calendarExpanded;
    render();
}

function goToday() {
    App.selectedDate = new Date();
    App.displayedMonth = new Date();
    render();
}

function pickCalendarDate(y, m, d) {
    App.selectedDate = new Date(y, m, d);
    render();
}

// === Settings ===
function renderSettings() {
    const themes = [
        { id: 'system', label: 'System', icon: '📱' },
        { id: 'light', label: 'Light', icon: '☀️' },
        { id: 'dark', label: 'Dark', icon: '🌙' }
    ];
    
    return `
        <div class="settings-section">
            <div class="settings-section-header">THEME</div>
            ${themes.map(th => `
                <div class="settings-row ${App.theme === th.id ? 'selected' : ''}" onclick="setTheme('${th.id}');render()">
                    <span>${th.icon}</span>
                    <label>${th.label}</label>
                    <span class="checkmark">✓</span>
                </div>
            `).join('')}
        </div>
        
        <div class="settings-section">
            <div class="settings-section-header">WORKING HOURS</div>
            <div class="settings-row">
                <label>Start time</label>
                <input type="time" value="${String(App.workStartHour).padStart(2,'0')}:00" onchange="setWorkStart(this.value)">
            </div>
            <div class="settings-row">
                <label>End time</label>
                <input type="time" value="${String(App.workEndHour).padStart(2,'0')}:00" onchange="setWorkEnd(this.value)">
            </div>
        </div>
        
        <div class="settings-section">
            <div class="settings-section-header">FILTERS</div>
            <div class="settings-row" style="justify-content:space-between">
                <label>Show clients only</label>
                <input type="checkbox" ${App.filterNoTitle ? 'checked' : ''} onchange="setFilter(this.checked)" style="width:20px;height:20px">
            </div>
        </div>
        
        <div class="settings-section">
            <div class="settings-section-header">CALENDAR SYNC</div>
            <div class="settings-row" onclick="exportICS()" style="cursor:pointer">
                <span>📤</span>
                <label>Export all visits (.ics)</label>
                <span style="color:var(--blue)">↓</span>
            </div>
            <div class="settings-row" onclick="triggerImport()" style="cursor:pointer">
                <span>📥</span>
                <label>Import from Calendar (.ics)</label>
                <span style="color:var(--blue)">↑</span>
            </div>
            <div style="padding:8px 16px 12px;font-size:11px;color:var(--text-secondary);line-height:1.4">
                Export visits as .ics file to open in iOS Calendar. Import .ics files exported from your Calendar app to sync visits here.
            </div>
        </div>
        
        <div class="settings-section">
            <div class="settings-section-header">ABOUT</div>
            <div class="settings-row"><label>Name</label><span class="text-secondary">Pediglam</span></div>
            <div class="settings-row"><label>Version</label><span class="text-secondary">1.0.0</span></div>
            <div class="settings-row"><label>Copyright</label><span class="text-secondary">© 2026 Pediglam</span></div>
        </div>
    `;
}

function setWorkStart(val) {
    App.workStartHour = parseInt(val.split(':')[0]);
    saveState();
}

function setWorkEnd(val) {
    App.workEndHour = parseInt(val.split(':')[0]);
    saveState();
}

function setFilter(val) {
    App.filterNoTitle = val;
    saveState();
}

// === Create Visit Modal ===
function showCreateVisit() {
    const sd = App.selectedDate;
    const dateStr = toDateInput(sd);
    const startStr = `${String(App.workStartHour).padStart(2,'0')}:00`;
    const endStr = `${String(App.workStartHour+1).padStart(2,'0')}:00`;
    
    showModal(`
        <h2>New Visit</h2>
        <div class="form-group">
            <label>Client name</label>
            <input type="text" id="cv-name" placeholder="Client name" autocomplete="off">
        </div>
        <div class="form-group">
            <label>Service note (optional)</label>
            <input type="text" id="cv-service" placeholder="e.g. manicure, pedicure" autocomplete="off">
        </div>
        <div class="form-group">
            <label>Date</label>
            <input type="date" id="cv-date" value="${dateStr}">
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>Start</label>
                <input type="time" id="cv-start" value="${startStr}">
            </div>
            <div class="form-group">
                <label>End</label>
                <input type="time" id="cv-end" value="${endStr}">
            </div>
        </div>
        <button class="btn-primary" onclick="saveNewVisit()">Save</button>
        <button class="btn-secondary mt-8" style="width:100%" onclick="closeModal()">Cancel</button>
    `);
}

function saveNewVisit() {
    const name = document.getElementById('cv-name').value.trim();
    if (!name) return;
    
    const dateVal = document.getElementById('cv-date').value;
    const startVal = document.getElementById('cv-start').value;
    const endVal = document.getElementById('cv-end').value;
    const service = document.getElementById('cv-service').value.trim();
    
    const [sy, sm, sd] = dateVal.split('-').map(Number);
    const [sh, smin] = startVal.split(':').map(Number);
    const [eh, emin] = endVal.split(':').map(Number);
    
    const startDate = new Date(sy, sm-1, sd, sh, smin, 0);
    const endDate = new Date(sy, sm-1, sd, eh, emin, 0);
    
    if (endDate <= startDate) {
        showToast('End time must be after start time');
        return;
    }
    
    const conflicts = conflictingEvents(startDate, endDate);
    if (conflicts.length > 0) {
        const conflictNames = conflicts.map(c => {
            const cs = new Date(c.startDate), ce = new Date(c.endDate);
            return `${c.clientName} (${fmtTime(cs)}–${fmtTime(ce)})`;
        }).join(', ');
        showToast(`Time conflict with: ${conflictNames}`);
        return;
    }
    
    addVisit(name, service, startDate, endDate);
    closeModal();
    render();
}

// === Toast ===
function showToast(msg) {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = msg;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

// === Modal ===
function showModal(html) {
    const overlay = document.createElement('div');
    overlay.className = 'overlay';
    overlay.id = 'modal-overlay';
    overlay.innerHTML = `<div class="modal">${html}</div>`;
    overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(); });
    document.body.appendChild(overlay);
}

function closeModal() {
    const overlay = document.getElementById('modal-overlay');
    if (overlay) overlay.remove();
}

// === Utilities ===
function esc(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

// === ICS Calendar Integration ===
function generateICS(visits) {
    let ics = 'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Pediglam//Web//EN\r\n';
    visits.forEach(v => {
        const s = new Date(v.startDate), e = new Date(v.endDate);
        const fmt = d => d.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '');
        ics += 'BEGIN:VEVENT\r\n';
        ics += `DTSTART:${fmt(s)}\r\n`;
        ics += `DTEND:${fmt(e)}\r\n`;
        ics += `SUMMARY:${v.clientName}` + (v.serviceNote ? ` - ${v.serviceNote}` : '') + '\r\n';
        ics += `UID:pediglam-${v.id}@pediglam.app\r\n`;
        ics += 'END:VEVENT\r\n';
    });
    ics += 'END:VCALENDAR\r\n';
    return ics;
}

function exportICS() {
    const ics = generateICS(App.visits);
    const blob = new Blob([ics], { type: 'text/calendar;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a'); a.href = url; a.download = 'pediglam_visits.ics';
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function exportVisitICS(id) {
    const v = getVisitById(id);
    if (!v) return;
    const ics = generateICS([v]);
    const blob = new Blob([ics], { type: 'text/calendar;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a'); a.href = url; a.download = `pediglam_${v.clientName.replace(/\s+/g,'_')}.ics`;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function importICS(file) {
    const reader = new FileReader();
    reader.onload = function(e) {
        const text = e.target.result;
        const events = [];
        const lines = text.split(/\r?\n/);
        let inEvent = false, event = {};
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line === 'BEGIN:VEVENT') { inEvent = true; event = {}; continue; }
            if (line === 'END:VEVENT') { inEvent = false; events.push(event); continue; }
            if (!inEvent) continue;
            
            // Handle folded lines (RFC 5545)
            let fullLine = line;
            while (i + 1 < lines.length && lines[i+1].startsWith(' ')) {
                i++;
                fullLine += lines[i].trim();
            }
            
            const match = fullLine.match(/^(DTSTART|DTEND|SUMMARY|UID)[;:](.+)$/i);
            if (match) {
                const key = match[1].toLowerCase();
                let val = match[2];
                
                if (key === 'dtstart' || key === 'dtend') {
                    // Parse ICS date format: 20260524T090000 or 20260524T090000Z
                    val = val.split(':').pop(); // Remove any TZID prefix
                    const year = parseInt(val.substring(0,4));
                    const month = parseInt(val.substring(4,6))-1;
                    const day = parseInt(val.substring(6,8));
                    const hour = val.length >= 13 ? parseInt(val.substring(9,11)) : 0;
                    const min = val.length >= 13 ? parseInt(val.substring(11,13)) : 0;
                    event[key] = new Date(year, month, day, hour, min, 0);
                } else if (key === 'summary') {
                    event.summary = val.replace(/\\,/g, ',').replace(/\\;/g, ';').replace(/\\n/g, '\n');
                }
            }
        }
        
        let imported = 0;
        events.forEach(ev => {
            if (ev.dtstart && ev.dtend && ev.summary) {
                // Parse: "ClientName - Service" or "ClientName"
                let name = ev.summary, service = '';
                const sepIdx = name.indexOf(' - ');
                if (sepIdx > 0) { service = name.substring(sepIdx + 3); name = name.substring(0, sepIdx); }
                
                // Check conflicts
                const conflicts = conflictingEvents(ev.dtstart, ev.dtend);
                if (conflicts.length === 0) {
                    addVisit(name, service, ev.dtstart, ev.dtend);
                    imported++;
                }
            }
        });
        
        showToast(`Imported ${imported} visits${imported < events.length ? ` (${events.length - imported} skipped due to conflicts)` : ''}`);
        render();
    };
    reader.readAsText(file);
}

function triggerImport() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.ics,text/calendar';
    input.onchange = function() { if (this.files[0]) importICS(this.files[0]); };
    input.click();
}

// === Boot ===
document.addEventListener('DOMContentLoaded', init);
