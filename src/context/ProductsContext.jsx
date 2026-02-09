import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { products as seedProducts } from "../data/products";

const STORAGE_KEY = "pixoraProducts";
const ProductsContext = createContext(null);

const loadProducts = () => {
  if (typeof window === "undefined") return seedProducts;
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) return seedProducts;
  try {
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) && parsed.length ? parsed : seedProducts;
  } catch {
    return seedProducts;
  }
};

export function ProductsProvider({ children }) {
  const [products, setProducts] = useState(loadProducts);

  useEffect(() => {
    if (typeof window === "undefined") return;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(products));
  }, [products]);

  const addProduct = (product) => {
    setProducts((prev) => [product, ...prev]);
  };

  const updateProduct = (id, patch) => {
    setProducts((prev) =>
      prev.map((item) => (item.id === id ? { ...item, ...patch } : item)),
    );
  };

  const removeProduct = (id) => {
    setProducts((prev) => prev.filter((item) => item.id !== id));
  };

  const upsertProduct = (product) => {
    setProducts((prev) => {
      const index = prev.findIndex((item) => item.id === product.id);
      if (index === -1) return [product, ...prev];
      const next = [...prev];
      next[index] = { ...prev[index], ...product };
      return next;
    });
  };

  const value = useMemo(
    () => ({
      products,
      setProducts,
      addProduct,
      updateProduct,
      removeProduct,
      upsertProduct,
    }),
    [products],
  );

  return <ProductsContext.Provider value={value}>{children}</ProductsContext.Provider>;
}

export function useProducts() {
  const ctx = useContext(ProductsContext);
  if (!ctx) {
    throw new Error("useProducts must be used inside ProductsProvider");
  }
  return ctx;
}
