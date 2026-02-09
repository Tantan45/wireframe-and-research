import React, { createContext, useContext, useMemo, useState } from "react";

const CartContext = createContext(null);

export function CartProvider({ children }) {
  const [items, setItems] = useState([]);

  const addItem = (product, qty = 1) => {
    setItems((prev) => {
      const existing = prev.find((item) => item.id === product.id);
      if (existing) {
        return prev.map((item) =>
          item.id === product.id ? { ...item, quantity: item.quantity + qty } : item,
        );
      }
      return [...prev, { ...product, quantity: qty }];
    });
  };

  const updateQuantity = (id, quantity) => {
    setItems((prev) =>
      prev
        .map((item) => (item.id === id ? { ...item, quantity } : item))
        .filter((item) => item.quantity > 0),
    );
  };

  const removeItem = (id) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  };

  const clearCart = () => setItems([]);

  const summary = useMemo(() => {
    const itemCount = items.reduce((acc, item) => acc + item.quantity, 0);
    const subtotal = items.reduce((acc, item) => acc + item.price * item.quantity, 0);
    return { itemCount, subtotal };
  }, [items]);

  const value = useMemo(
    () => ({
      items,
      addItem,
      updateQuantity,
      removeItem,
      clearCart,
      itemCount: summary.itemCount,
      subtotal: summary.subtotal,
    }),
    [items, summary],
  );

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) {
    throw new Error("useCart must be used inside CartProvider");
  }
  return ctx;
}
