import type { APIRoute } from "astro";
import Stripe from "stripe";
import { getProductoPorId } from "../../../lib/productos";
import { getUsuarioDesdeCookies } from "../../../lib/auth";

const stripe = new Stripe(import.meta.env.STRIPE_SECRET_KEY);

export const POST: APIRoute = async ({ request, cookies }) => {
    try {
        const sesion = await getUsuarioDesdeCookies(cookies);

        if (!sesion.user) {
            return new Response(
                JSON.stringify({
                    error:
                        sesion.error === "sin-sesion"
                            ? "Debes iniciar sesión para comprar"
                            : "Sesión no válida",
                }),
                { status: 401 }
            );
        }

        const userId = sesion.user.id;

        const { productos } = await request.json();

        if (!Array.isArray(productos) || productos.length === 0) {
            return new Response(
                JSON.stringify({ error: "El carrito está vacío" }),
                { status: 400 }
            );
        }

        const line_items: Stripe.Checkout.SessionCreateParams.LineItem[] = [];

        for (const item of productos) {
            const id = Number(item.id);
            const cantidad = Number(item.cantidad);

            if (
                !Number.isSafeInteger(id) ||
                id <= 0 ||
                !Number.isSafeInteger(cantidad) ||
                cantidad <= 0
            ) {
                return new Response(
                    JSON.stringify({ error: "Producto o cantidad no válidos" }),
                    { status: 400 }
                );
            }

            const producto = await getProductoPorId(id);

            if (!producto || producto.stock < cantidad) {
                return new Response(
                    JSON.stringify({
                        error: "Producto no disponible o stock insuficiente",
                    }),
                    { status: 400 }
                );
            }

            const precio = Number(producto.precio);

            if (!Number.isFinite(precio) || precio <= 0) {
                return new Response(
                    JSON.stringify({ error: "Precio no válido" }),
                    { status: 400 }
                );
            }

            line_items.push({
                price_data: {
                    currency: "eur",
                    product_data: {
                        name: producto.nombre_producto,
                            metadata: {
                                producto_id: String(id),
                            },
                    },
                    unit_amount: Math.round(precio * 100),
                },
                quantity: cantidad,
            });
        }

        const session = await stripe.checkout.sessions.create({
            mode: "payment",
            line_items,
            success_url: `${new URL(request.url).origin}/pago-exitoso?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: new URL("/carrito", request.url).toString(),
            metadata: {
                userId: userId,
            },
        });

        return new Response(
            JSON.stringify({ url: session.url }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error) {
        console.error("Error al crear el pago:", error);

        return new Response(
            JSON.stringify({ error: "No se pudo iniciar el pago" }),
            { status: 500 }
        );
    }
};
