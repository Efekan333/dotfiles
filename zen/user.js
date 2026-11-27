// Zen prefs, copied into prefs.js on every start (user.js wins over UI changes).
// Linked into the profile by scripts/link-zen.sh.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // load chrome/userChrome.css
user_pref("zen.view.window.scheme", 0);                        // 0 dark, 1 light, 2 system
user_pref("layout.css.prefers-color-scheme.content-override", 0); // sites get prefers-color-scheme: dark
user_pref("browser.display.background_color.dark", "#0c0c0c");  // blank / unstyled page bg
// Default fonts = fallbacks only; sites that set their own font keep it.
user_pref("font.name.serif.x-western", "Rice Mono");
user_pref("font.name.sans-serif.x-western", "Rice Mono");
user_pref("font.name.monospace.x-western", "Courier Prime Code");
