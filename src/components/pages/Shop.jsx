import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";
import { useCart } from "../../context/CartContext";
import { useProducts } from "../../context/ProductsContext";

const formatPrice = (value) => `PHP ${Number(value).toLocaleString("en-PH")}`;

export default function Shop() {
  const { addItem } = useCart();
  const { products: allProducts } = useProducts();
  const [activeCategory, setActiveCategory] = useState("All");

  const categoryFilters = useMemo(
    () => ["All", ...new Set(allProducts.map((item) => item.category))],
    [allProducts],
  );

  const products = useMemo(() => {
    if (activeCategory === "All") return allProducts;
    return allProducts.filter((item) => item.category === activeCategory);
  }, [activeCategory, allProducts]);

  return (
    <div className="space-y-10">
      <section className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div>
            <p className="text-sm font-semibold text-[var(--accent)]">Shop</p>
            <h1 className="serif mt-2 text-3xl sm:text-4xl font-semibold text-slate-900">
              All Fujifilm camera, lenses, and creator gear
            </h1>
            <p className="mt-3 text-sm text-slate-600">
              Explore every item in the Pixora catalog, with category filters
              for quick browsing.
            </p>
          </div>
          <Link
            to="/cart"
            className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:border-slate-300"
          >
            Go to cart
          </Link>
        </div>
        <div className="mt-6 flex flex-wrap gap-2">
          {categoryFilters.map((category) => (
            <button
              key={category}
              type="button"
              onClick={() => setActiveCategory(category)}
              className={`rounded-full px-4 py-2 text-xs font-semibold transition ${
                activeCategory === category
                  ? "bg-slate-900 text-white"
                  : "border border-slate-200 bg-white text-slate-600 hover:border-slate-300"
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </section>

      <section className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {products.map((product) => (
          <motion.div
            key={product.id}
            whileHover={{ y: -6 }}
            className="group rounded-3xl border border-slate-200 bg-white p-4 shadow-sm"
          >
            <Link
              to={`/product/${product.id}`}
              className="block"
              aria-label={`View ${product.name}`}
            >
              <div
                className="h-52 rounded-2xl bg-cover bg-center transition-transform duration-300 group-hover:scale-[1.02]"
                style={{ backgroundImage: `url(${product.image})` }}
                aria-label={product.name}
              />
              <div className="mt-4 space-y-2">
                <p className="text-xs uppercase tracking-wide text-slate-500">
                  {product.category}
                </p>
                <h3 className="text-lg font-semibold text-slate-900">
                  {product.name}
                </h3>
                <p className="text-sm text-slate-600">
                  {formatPrice(product.price)}
                </p>
              </div>
            </Link>
            <div className="mt-4 flex gap-3">
              <button
                onClick={() => addItem(product, 1)}
                className="flex-1 rounded-full bg-slate-900 px-4 py-2 text-sm font-semibold text-white hover:bg-slate-800"
              >
                Add to cart
              </button>
              <Link
                to={`/product/${product.id}`}
                className="flex-1 rounded-full border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-700 text-center hover:border-slate-300"
              >
                View
              </Link>
            </div>
          </motion.div>
        ))}
      </section>
    </div>
  );
}
