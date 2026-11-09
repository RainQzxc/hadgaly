'use strict';

const status = document.getElementById('status');
const signIn = document.getElementById('sign-in');
const signUp = document.getElementById('sign-up');
const signOut = document.getElementById('sign-out');
const retry = document.getElementById('retry');
const buttons = [signIn, signUp, signOut];
const returnUrl = new URL('/auth/index.html', location.origin).href;
let clerk;

function loadScript(url, key) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    const timeout = setTimeout(() => {
      script.remove();
      reject(new Error('Clerk script timeout'));
    }, 12000);
    script.crossOrigin = 'anonymous';
    script.src = url;
    if (key) script.dataset.clerkPublishableKey = key;
    script.onload = () => { clearTimeout(timeout); resolve(); };
    script.onerror = () => { clearTimeout(timeout); reject(new Error('Clerk script failed')); };
    document.head.append(script);
  });
}

function render() {
  const signedIn = clerk.isSignedIn === true;
  status.textContent = signedIn ? 'Нэвтэрсэн байна.' : 'Нэвтрээгүй байна.';
  signIn.hidden = signUp.hidden = signedIn;
  signOut.hidden = !signedIn;
}

function fail() {
  status.textContent = 'Clerk-тэй холбогдож чадсангүй. Сүлжээгээ шалгаад дахин оролдоно уу.';
  retry.hidden = false;
}

async function run(action) {
  buttons.forEach((button) => { button.disabled = true; });
  try {
    await action();
  } catch {
    fail();
  } finally {
    buttons.forEach((button) => { button.disabled = false; });
  }
}

async function initialize() {
  const config = window.hadgalyClerk;
  if (!config?.key) {
    status.textContent = 'Энэ хувилбарт Clerk нэвтрэлт тохируулаагүй байна.';
    return;
  }
  if (!navigator.onLine) {
    fail();
    return;
  }
  await loadScript(config.origin + '/npm/@clerk/ui@1.42.4/dist/ui.browser.js');
  await loadScript(config.origin + '/npm/@clerk/clerk-js@6.42.3/dist/clerk.browser.js', config.key);
  clerk = window.Clerk;
  await clerk.load({
    ui: { ClerkUI: window.__internal_ClerkUICtor },
    telemetry: { disabled: true },
    signInForceRedirectUrl: returnUrl,
    signUpForceRedirectUrl: returnUrl,
    afterSignOutUrl: returnUrl,
  });
  clerk.addListener(render);
  render();
}

signIn.onclick = () => run(() => clerk.redirectToSignIn());
signUp.onclick = () => run(() => clerk.redirectToSignUp());
signOut.onclick = () => run(async () => { await clerk.signOut(); render(); });
retry.onclick = () => location.reload();
initialize().catch(fail);
