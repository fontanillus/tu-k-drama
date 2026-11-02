// Lógica compartida del carrito (localStorage + evento "cestaUpdated").
// Se usa desde los scripts de cliente de Header, productos, producto y carrito.

export interface ProductoCarrito {
    id: string;
    nombre: string;
    precio: number;
    cantidad: number;
    stock: number;
}

export type ResultadoAgregar =
    | { ok: true }
    | { ok: false; motivo: "sin-stock" }
    | { ok: false; motivo: "stock-maximo"; enCarrito: number };

export function leerCarrito(): ProductoCarrito[] {
    return JSON.parse(localStorage.getItem("carrito") || "[]");
}

// Guarda el carrito y avisa al Header de que ha cambiado.
export function guardarCarrito(carrito: ProductoCarrito[]): void {
    localStorage.setItem("carrito", JSON.stringify(carrito));
    window.dispatchEvent(new Event("cestaUpdated"));
}

export function contarUnidades(): number {
    return leerCarrito().reduce(
        (suma, producto) => suma + producto.cantidad,
        0
    );
}

export function agregarAlCarrito(
    datos: { id: string; nombre: string; precio: number; stock: number },
    cantidad = 1
): ResultadoAgregar {
    if (datos.stock <= 0) {
        return { ok: false, motivo: "sin-stock" };
    }

    const carrito = leerCarrito();
    const existente = carrito.find((producto) => producto.id === datos.id);

    if (existente) {
        if (existente.cantidad + cantidad > datos.stock) {
            return {
                ok: false,
                motivo: "stock-maximo",
                enCarrito: existente.cantidad,
            };
        }

        existente.cantidad += cantidad;
        existente.stock = datos.stock;
    } else {
        carrito.push({
            id: datos.id,
            nombre: datos.nombre,
            precio: datos.precio,
            cantidad,
            stock: datos.stock,
        });
    }

    guardarCarrito(carrito);
    return { ok: true };
}
