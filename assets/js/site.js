// Page behaviour. All of it is optional: with JavaScript off the page reads
// in full, the clocks show their placeholder and the marquee stands still.

const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// ---------- clocks ----------
// The top bar always shows Spanish time, whatever the visitor's time zone.
// The footer shows the visitor's own local time.
const spainTime = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Europe/Madrid',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hourCycle: 'h23',
  timeZoneName: 'short',
});
const localTime = new Intl.DateTimeFormat('en-GB', {
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hourCycle: 'h23',
});

const spainClock = document.querySelector('[data-clock="spain"]');
const localClock = document.querySelector('[data-clock="local"]');

function tick() {
  const now = new Date();
  if (spainClock) {
    const parts = spainTime.formatToParts(now);
    const zone = parts.find((part) => part.type === 'timeZoneName')?.value ?? '';
    const time = parts
      .filter((part) => ['hour', 'minute', 'second', 'literal'].includes(part.type))
      .map((part) => part.value)
      .join('')
      .trim();
    spainClock.textContent = `${time} · ${zone}`;
  }
  if (localClock) {
    localClock.textContent = `LOCAL ${localTime.format(now)}`;
  }
}

tick();
setInterval(tick, 1000);

// ---------- marquee ----------
// One copy of the topics lives in the HTML. The scroll needs a second copy
// to loop seamlessly; it is hidden from screen readers so they read it once.
const marqueeTrack = document.querySelector('.marquee__track');
if (marqueeTrack && !reduceMotion) {
  const copy = marqueeTrack.firstElementChild.cloneNode(true);
  copy.setAttribute('aria-hidden', 'true');
  marqueeTrack.append(copy);
  marqueeTrack.classList.add('is-running');
}

// ---------- reveal on scroll ----------
if (!reduceMotion && 'IntersectionObserver' in window) {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      }
    },
    { threshold: 0.12 },
  );

  document
    .querySelectorAll('.section-head, .repo-card, .stats__item, .principle, .terminal')
    .forEach((element) => {
      element.classList.add('reveal');
      observer.observe(element);
    });
}
