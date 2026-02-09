import { useState } from "react";
import { Link, NavLink, Outlet } from "react-router-dom";
import { useCart } from "./context/CartContext.jsx";

const navItems = [
  { label: "Home", to: "/" },
  { label: "Shop", to: "/shop" },
  { label: "Cart", to: "/cart" },
  { label: "Account", to: "/login", mobileLabel: "Acc" },
];

export default function App({ children }) {
  const { itemCount } = useCart();
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => setIsMenuOpen((prev) => !prev);
  const closeMenu = () => setIsMenuOpen(false);

  return (
    <div className="min-h-screen bg-[var(--canvas)] text-[var(--ink)]">
      <div className="pointer-events-none fixed inset-x-0 top-0 h-64 bg-gradient-to-br from-gray via-transparent to-amber-100/60" />
      <header className="sticky top-0 z-30 border-b border-slate-200/70 bg-white/80 backdrop-blur relative">
        <div className="mx-auto flex max-w-6xl items-center gap-6 px-4 py-4">
          <Link to="/" className="text-xl font-semibold serif tracking-tight">
            Pixora
          </Link>
          <nav className="hidden md:flex items-center gap-4 text-sm font-semibold">
            {navItems.map((item) => (
              <NavLink
                key={item.label}
                to={item.to}
                className={({ isActive }) =>
                  `transition ${
                    isActive
                      ? "text-[var(--accent)]"
                      : "text-slate-600 hover:text-slate-900"
                  }`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
          <div className="ml-auto hidden md:flex items-center gap-3">
            <div className="hidden lg:flex items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-2 text-xs text-slate-500">
              <span className="h-2 w-2 rounded-full bg-[var(--accent)]" />
              Shipping in 2 to 5 days
            </div>
            <Link
              to="/cart"
              className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:border-slate-300"
            >
              Cart
              <span className="ml-2 rounded-full bg-slate-900 px-2 py-0.5 text-xs text-white">
                {itemCount}
              </span>
            </Link>
            <Link
              to="/login"
              className="rounded-full bg-[var(--accent)] px-4 py-2 text-sm font-semibold text-white shadow-sm hover:opacity-90"
            >
              Sign in
            </Link>
          </div>
          <button
            type="button"
            onClick={toggleMenu}
            aria-expanded={isMenuOpen}
            aria-controls="mobile-nav"
            aria-label={isMenuOpen ? "Close menu" : "Open menu"}
            className="ml-auto inline-flex items-center justify-center rounded-full border border-slate-200 bg-white p-3 text-slate-700 shadow-sm transition hover:border-slate-300 md:hidden"
          >
            <span className="sr-only">
              {isMenuOpen ? "Close menu" : "Open menu"}
            </span>
            <span className="flex flex-col gap-1.5">
              <span
                className={`block h-0.5 w-5 bg-slate-900 transition ${
                  isMenuOpen ? "translate-y-2 rotate-45" : ""
                }`}
              />
              <span
                className={`block h-0.5 w-5 bg-slate-900 transition ${
                  isMenuOpen ? "opacity-0" : ""
                }`}
              />
              <span
                className={`block h-0.5 w-5 bg-slate-900 transition ${
                  isMenuOpen ? "-translate-y-2 -rotate-45" : ""
                }`}
              />
            </span>
          </button>
        </div>
        {isMenuOpen && (
          <>
            <button
              type="button"
              aria-label="Close menu"
              onClick={closeMenu}
              className="fixed inset-0 z-20 bg-slate-900/25 md:hidden"
            />
            <div
              id="mobile-nav"
              className="absolute inset-x-0 top-full z-30 border-b border-slate-200 bg-white/95 backdrop-blur md:hidden"
            >
              <div className="mx-auto grid max-w-6xl gap-2 px-4 py-4 text-sm font-semibold">
                {navItems.map((item) => (
                  <NavLink
                    key={item.label}
                    to={item.to}
                    onClick={closeMenu}
                    className={({ isActive }) =>
                      `rounded-2xl px-4 py-3 transition ${
                        isActive
                          ? "bg-slate-900 text-white"
                          : "text-slate-700 hover:bg-slate-100"
                      }`
                    }
                  >
                    <span className="flex items-center justify-between">
                      <span>{item.mobileLabel ?? item.label}</span>
                      {item.label === "Cart" ? (
                        <span className="rounded-full bg-slate-900 px-2 py-0.5 text-xs text-white">
                          {itemCount}
                        </span>
                      ) : null}
                    </span>
                  </NavLink>
                ))}
              </div>
            </div>
          </>
        )}
      </header>

      <main className="relative z-10 mx-auto max-w-6xl px-4 py-10">
        {children ?? <Outlet />}
      </main>

      <footer className="border-t border-slate-200/70 bg-white/80">
        <div className="mx-auto max-w-6xl px-4 py-10 grid gap-6 md:grid-cols-3 text-sm text-slate-600">
          <div>
            <p className="serif text-lg font-semibold text-slate-900">
              Pixora Store
            </p>
            <p className="mt-2">
              Curated cameras, lenses, and studio-ready accessories for modern
              creators.
            </p>
          </div>
          <div className="space-y-2">
            <p className="text-slate-900 font-semibold">Support</p>
            <p>Delivery and returns</p>
            <p>Warranty coverage</p>
            <p>Contact: jonathanpalomar85@gmail.com</p>
          </div>
          <div className="space-y-2">
            <p className="text-slate-900 font-semibold">Showroom</p>
            <p>Open Monday to Saturday, 10AM to 6PM</p>
            <p>Nueva Ecija, Cabanatuan City, Brgy Cabu, Philippines</p>
            <p>Phone: +63 9152486509</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
