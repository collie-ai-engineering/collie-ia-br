document.addEventListener('DOMContentLoaded', () => {
  const navbar = document.getElementById('navbar');
  const menuButton = document.querySelector('.mobile-menu-btn');
  const nav = document.getElementById('primary-navigation');
  const navLinks = document.querySelectorAll('.nav-link');
  const fadeElements = document.querySelectorAll('.fade-in-up');

  /* Navbar scroll state */
  const updateNavbar = () => {
    navbar.classList.toggle('scrolled', window.scrollY > 24);
  };
  updateNavbar();
  window.addEventListener('scroll', updateNavbar, { passive: true });

  /* Mobile menu */
  const closeMenu = () => {
    document.body.classList.remove('menu-open');
    menuButton.classList.remove('active');
    menuButton.setAttribute('aria-expanded', 'false');
  };

  menuButton.addEventListener('click', () => {
    const isOpen = document.body.classList.toggle('menu-open');
    menuButton.classList.toggle('active', isOpen);
    menuButton.setAttribute('aria-expanded', String(isOpen));
  });

  navLinks.forEach((link) => link.addEventListener('click', closeMenu));

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeMenu();
  });

  /* Fade-in animations with stagger */
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (prefersReducedMotion || !('IntersectionObserver' in window)) {
    fadeElements.forEach((el) => el.classList.add('visible'));
    return;
  }

  const observer = new IntersectionObserver((entries, obs) => {
    /* Group entries by their parent section for stagger */
    const parentGroups = new Map();

    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;

      const section = entry.target.closest('section') || entry.target.parentElement;
      if (!parentGroups.has(section)) {
        parentGroups.set(section, []);
      }
      parentGroups.get(section).push(entry.target);
    });

    parentGroups.forEach((elements) => {
      elements.forEach((el, i) => {
        const delay = i * 80;
        el.style.transitionDelay = delay + 'ms';
        el.classList.add('visible');
        obs.unobserve(el);

        /* Clean up delay after animation completes */
        el.addEventListener('transitionend', () => {
          el.style.transitionDelay = '';
        }, { once: true });
      });
    });
  }, { threshold: 0.25 });

  fadeElements.forEach((el) => observer.observe(el));
});
