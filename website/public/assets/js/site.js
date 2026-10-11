/* Gentle website: header state, mobile menu, reveals, pricing toggle,
   breathing exercise and a small Web Audio soundscape engine. No dependencies. */
(function () {
  "use strict";
  document.documentElement.classList.add("js");
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- Header: solid once the hero scrolls away ---------- */
  var header = document.querySelector(".site-header");
  var sentinel = document.getElementById("top-sentinel");
  if (header && sentinel && !header.hasAttribute("data-solid") && "IntersectionObserver" in window) {
    new IntersectionObserver(function (entries) {
      header.classList.toggle("is-solid", !entries[0].isIntersecting);
    }).observe(sentinel);
  }

  /* ---------- Mobile menu ---------- */
  var menu = document.getElementById("mobile-menu");
  var openBtn = document.querySelector("[data-menu-open]");
  var closeBtn = document.querySelector("[data-menu-close]");
  function setMenu(open) {
    if (!menu) return;
    menu.classList.toggle("is-open", open);
    menu.setAttribute("aria-hidden", open ? "false" : "true");
    if (openBtn) openBtn.setAttribute("aria-expanded", open ? "true" : "false");
    document.body.style.overflow = open ? "hidden" : "";
    if (open && closeBtn) closeBtn.focus();
    if (!open && openBtn) openBtn.focus();
  }
  if (openBtn) openBtn.addEventListener("click", function () { setMenu(true); });
  if (closeBtn) closeBtn.addEventListener("click", function () { setMenu(false); });
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && menu && menu.classList.contains("is-open")) setMenu(false);
  });

  /* ---------- Reveal on scroll ---------- */
  var revealEls = document.querySelectorAll("[data-reveal]");
  if ("IntersectionObserver" in window && !reduceMotion) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) { entry.target.classList.add("is-in"); io.unobserve(entry.target); }
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.12 });
    revealEls.forEach(function (el) { io.observe(el); });
  } else {
    revealEls.forEach(function (el) { el.classList.add("is-in"); });
  }

  /* ---------- Range fill (webkit track) ---------- */
  function paintRange(input) {
    var min = +input.min || 0, max = +input.max || 100;
    input.style.setProperty("--fill", ((input.value - min) / (max - min)) * 100 + "%");
  }
  document.querySelectorAll('input[type="range"]').forEach(function (r) {
    paintRange(r);
    r.addEventListener("input", function () { paintRange(r); });
  });

  /* ---------- Pricing toggle ---------- */
  var toggle = document.querySelector("[data-price-toggle]");
  if (toggle) {
    var thumb = toggle.querySelector(".thumb");
    var options = toggle.querySelectorAll("button");
    function moveThumb(btn) {
      thumb.style.width = btn.offsetWidth + "px";
      thumb.style.transform = "translateX(" + btn.offsetLeft + "px)";
    }
    function setPeriod(period) {
      options.forEach(function (b) {
        var on = b.dataset.period === period;
        b.setAttribute("aria-checked", on ? "true" : "false");
        if (on) moveThumb(b);
      });
      document.querySelectorAll("[data-" + period + "]").forEach(function (el) {
        el.innerHTML = el.getAttribute("data-" + period);
      });
    }
    options.forEach(function (b) { b.addEventListener("click", function () { setPeriod(b.dataset.period); }); });
    var initial = toggle.querySelector('[aria-checked="true"]');
    thumb.style.transition = "none";
    setPeriod(initial ? initial.dataset.period : "yearly");
    requestAnimationFrame(function () { thumb.style.transition = ""; });
    window.addEventListener("resize", function () { moveThumb(toggle.querySelector('[aria-checked="true"]')); });
  }

  /* ---------- Breathing exercise ---------- */
  var breath = document.querySelector("[data-breath]");
  if (breath) {
    var orb = breath.querySelector(".breath-orb");
    var word = breath.querySelector("[data-breath-word]");
    var count = breath.querySelector("[data-breath-count]");
    var startBtn = breath.querySelector("[data-breath-start]");
    var patternBtns = breath.querySelectorAll("[data-pattern]");
    var patterns = {
      rust: [["Adem in", 4, 1], ["Adem uit", 6, 0]],
      box: [["Adem in", 4, 1], ["Houd vast", 4, 1], ["Adem uit", 4, 0], ["Houd vast", 4, 0]],
      "478": [["Adem in", 4, 1], ["Houd vast", 7, 1], ["Adem uit", 8, 0]]
    };
    var current = "rust", running = false, timer = null, tick = null;

    function setOrb(expanded, seconds) {
      orb.style.transitionDuration = seconds + "s";
      orb.style.transform = reduceMotion ? "" : (expanded ? "scale(1)" : "scale(0.72)");
      orb.style.opacity = expanded ? "1" : "0.55";
    }
    function runStep(i) {
      var steps = patterns[current];
      var step = steps[i % steps.length];
      var left = step[1];
      word.textContent = step[0];
      count.textContent = left;
      setOrb(step[2] === 1, step[1]);
      clearInterval(tick);
      tick = setInterval(function () {
        left -= 1;
        if (left > 0) count.textContent = left;
      }, 1000);
      timer = setTimeout(function () { runStep(i + 1); }, step[1] * 1000);
    }
    function stop() {
      running = false;
      clearTimeout(timer); clearInterval(tick);
      setOrb(false, 1.2);
      word.textContent = "Klaar wanneer jij het bent";
      count.textContent = "Druk op start";
      startBtn.innerHTML = '<i class="ph-light ph-play"></i>Start';
      startBtn.setAttribute("aria-pressed", "false");
    }
    startBtn.addEventListener("click", function () {
      if (running) return stop();
      running = true;
      startBtn.innerHTML = '<i class="ph-light ph-pause"></i>Stop';
      startBtn.setAttribute("aria-pressed", "true");
      runStep(0);
    });
    patternBtns.forEach(function (b) {
      b.addEventListener("click", function () {
        current = b.dataset.pattern;
        patternBtns.forEach(function (o) { o.setAttribute("aria-checked", o === b ? "true" : "false"); });
        if (running) { clearTimeout(timer); runStep(0); }
      });
    });
    document.addEventListener("visibilitychange", function () { if (document.hidden && running) stop(); });
  }

  /* ---------- Soundscape engine (synthesised, nothing to download) ---------- */
  var Sound = (function () {
    var ctx = null, master = null, voices = {}, listeners = [];
    var DEFAULTS = { regen: 0.6, zee: 0.5, wind: 0.45, brom: 0.5 };
    var levels = Object.assign({}, DEFAULTS);
    var masterLevel = 0.7;

    function noiseBuffer(type) {
      var seconds = 6, rate = ctx.sampleRate, len = seconds * rate;
      var buf = ctx.createBuffer(2, len, rate);
      for (var ch = 0; ch < 2; ch++) {
        var d = buf.getChannelData(ch);
        var b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0, last = 0;
        for (var i = 0; i < len; i++) {
          var w = Math.random() * 2 - 1;
          if (type === "pink") {
            b0 = 0.99886 * b0 + w * 0.0555179; b1 = 0.99332 * b1 + w * 0.0750759;
            b2 = 0.969 * b2 + w * 0.153852; b3 = 0.8665 * b3 + w * 0.3104856;
            b4 = 0.55 * b4 + w * 0.5329522; b5 = -0.7616 * b5 - w * 0.016898;
            d[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) * 0.11; b6 = w * 0.115926;
          } else if (type === "brown") {
            last = (last + 0.02 * w) / 1.02; d[i] = last * 3.5;
          } else { d[i] = w; }
        }
        // soften the loop seam
        var fade = Math.floor(rate * 0.05);
        for (var j = 0; j < fade; j++) { var g = j / fade; d[j] *= g; d[len - 1 - j] *= g; }
      }
      return buf;
    }
    function lfo(freq, depth, target) {
      var o = ctx.createOscillator(), g = ctx.createGain();
      o.frequency.value = freq; g.gain.value = depth;
      o.connect(g); g.connect(target); o.start();
      return o;
    }
    function build(name) {
      var src = ctx.createBufferSource(); src.loop = true;
      var out = ctx.createGain(); out.gain.value = 0;
      var chain;
      if (name === "regen") {
        src.buffer = noiseBuffer("pink");
        var hp = ctx.createBiquadFilter(); hp.type = "highpass"; hp.frequency.value = 500;
        var lp = ctx.createBiquadFilter(); lp.type = "lowpass"; lp.frequency.value = 7000;
        src.connect(hp); hp.connect(lp); chain = lp;
      } else if (name === "zee") {
        src.buffer = noiseBuffer("brown");
        var lp2 = ctx.createBiquadFilter(); lp2.type = "lowpass"; lp2.frequency.value = 700;
        var swell = ctx.createGain(); swell.gain.value = 0.55;
        lfo(0.085, 0.45, swell.gain);
        lfo(0.085, 350, lp2.frequency);
        src.connect(lp2); lp2.connect(swell); chain = swell;
      } else if (name === "wind") {
        src.buffer = noiseBuffer("pink");
        var bp = ctx.createBiquadFilter(); bp.type = "bandpass"; bp.frequency.value = 650; bp.Q.value = 0.9;
        var gust = ctx.createGain(); gust.gain.value = 0.7;
        lfo(0.045, 380, bp.frequency);
        lfo(0.07, 0.3, gust.gain);
        src.connect(bp); bp.connect(gust); chain = gust;
      } else {
        src.buffer = noiseBuffer("brown");
        var lp3 = ctx.createBiquadFilter(); lp3.type = "lowpass"; lp3.frequency.value = 420;
        src.connect(lp3); chain = lp3;
      }
      chain.connect(out); out.connect(master); src.start();
      return { out: out, on: false };
    }
    function ensure() {
      if (!ctx) {
        var AC = window.AudioContext || window.webkitAudioContext;
        if (!AC) return false;
        ctx = new AC();
        master = ctx.createGain(); master.gain.value = masterLevel;
        var comp = ctx.createDynamicsCompressor();
        master.connect(comp); comp.connect(ctx.destination);
      }
      if (ctx.state === "suspended") ctx.resume();
      return true;
    }
    function ramp(param, value, seconds) {
      var now = ctx.currentTime;
      param.cancelScheduledValues(now);
      param.setValueAtTime(param.value, now);
      param.linearRampToValueAtTime(value, now + seconds);
    }
    function emit() { listeners.forEach(function (fn) { fn(api.state()); }); }

    var api = {
      supported: !!(window.AudioContext || window.webkitAudioContext),
      set: function (name, on, fade) {
        if (!ensure()) return;
        var v = voices[name] || (voices[name] = build(name));
        v.on = on;
        ramp(v.out.gain, on ? levels[name] * 0.5 : 0, fade == null ? (on ? 1.6 : 0.8) : fade);
        emit();
      },
      toggle: function (name) { api.set(name, !(voices[name] && voices[name].on)); },
      level: function (name, value) {
        levels[name] = value;
        var v = voices[name];
        if (ctx && v && v.on) ramp(v.out.gain, value * 0.5, 0.15);
      },
      master: function (value) { masterLevel = value; if (ctx) ramp(master.gain, value, 0.15); },
      stopAll: function (fade) { Object.keys(voices).forEach(function (n) { if (voices[n].on) api.set(n, false, fade); }); emit(); },
      isOn: function (name) { return !!(voices[name] && voices[name].on); },
      state: function () { var s = {}; Object.keys(DEFAULTS).forEach(function (n) { s[n] = api.isOn(n); }); return s; },
      anyOn: function () { return Object.keys(voices).some(function (n) { return voices[n].on; }); },
      subscribe: function (fn) { listeners.push(fn); }
    };
    return api;
  })();

  function syncSoundUI() {
    document.querySelectorAll("[data-sound]").forEach(function (el) {
      el.setAttribute("aria-pressed", Sound.isOn(el.dataset.sound) ? "true" : "false");
    });
    document.querySelectorAll("[data-sound-preset]").forEach(function (el) {
      var on = el.dataset.soundPreset.split(",").some(function (n) { return Sound.isOn(n.split(":")[0]); });
      el.setAttribute("aria-pressed", on ? "true" : "false");
      el.classList.toggle("is-playing", on);
      var label = el.querySelector("[data-label]");
      if (label) label.textContent = on ? "Geluid uit" : el.dataset.labelOff;
    });
    var any = Sound.anyOn();
    document.querySelectorAll("[data-sound-status]").forEach(function (el) {
      el.classList.toggle("is-playing", any);
      var t = el.querySelector("[data-status-text]");
      if (t && !timerEnd) t.textContent = any ? "Speelt nu" : "Stil";
    });
    document.querySelectorAll("[data-level]").forEach(function (r) { r.disabled = !Sound.isOn(r.dataset.level); });
  }
  Sound.subscribe(syncSoundUI);

  if (!Sound.supported) {
    document.querySelectorAll("[data-sound], [data-sound-preset]").forEach(function (el) { el.hidden = true; });
  }
  document.querySelectorAll("[data-sound]").forEach(function (el) {
    el.addEventListener("click", function () { Sound.toggle(el.dataset.sound); });
  });
  document.querySelectorAll("[data-sound-preset]").forEach(function (el) {
    el.dataset.labelOff = (el.querySelector("[data-label]") || {}).textContent || "";
    el.addEventListener("click", function () {
      var parts = el.dataset.soundPreset.split(",");
      var on = parts.some(function (p) { return Sound.isOn(p.split(":")[0]); });
      parts.forEach(function (p) {
        var kv = p.split(":");
        if (!on && kv[1]) Sound.level(kv[0], +kv[1]);
        Sound.set(kv[0], !on);
      });
    });
  });
  document.querySelectorAll("[data-level]").forEach(function (r) {
    r.addEventListener("input", function () { Sound.level(r.dataset.level, r.value / 100); });
  });
  var masterRange = document.querySelector("[data-master]");
  if (masterRange) masterRange.addEventListener("input", function () { Sound.master(masterRange.value / 100); });
  var stopBtn = document.querySelector("[data-sound-stop]");
  if (stopBtn) stopBtn.addEventListener("click", function () { clearSleepTimer(); Sound.stopAll(); });

  /* Sleep timer: fades everything out over 20 seconds when it runs out */
  var timerEnd = 0, timerTick = null;
  function clearSleepTimer() {
    timerEnd = 0; clearInterval(timerTick);
    document.querySelectorAll("[data-timer]").forEach(function (b) { b.setAttribute("aria-checked", b.dataset.timer === "0" ? "true" : "false"); });
    syncSoundUI();
  }
  document.querySelectorAll("[data-timer]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      clearSleepTimer();
      var minutes = +btn.dataset.timer;
      document.querySelectorAll("[data-timer]").forEach(function (b) { b.setAttribute("aria-checked", b === btn ? "true" : "false"); });
      if (!minutes) return;
      timerEnd = Date.now() + minutes * 60000;
      var text = document.querySelector("[data-sound-status] [data-status-text]");
      var update = function () {
        var left = Math.max(0, timerEnd - Date.now());
        if (left === 0) { Sound.stopAll(20); clearSleepTimer(); return; }
        var m = Math.floor(left / 60000), s = Math.floor((left % 60000) / 1000);
        if (text) text.textContent = "Stopt over " + m + ":" + (s < 10 ? "0" : "") + s;
      };
      update();
      timerTick = setInterval(update, 1000);
    });
  });
})();
