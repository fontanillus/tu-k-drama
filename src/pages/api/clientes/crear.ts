import type { APIRoute } from "astro";
import pool from "../../../lib/db";
import { getUsuarioDesdeCookies } from "../../../lib/auth";

export const POST: APIRoute = async ({ request, cookies }) => {
    const formData = await request.formData();

    const nombres_cliente = formData.get("nombres_cliente") as string;
    const apellido1_cliente = formData.get("apellido1_cliente") as string;
    const apellido2_cliente = formData.get("apellido2_cliente") as string;
    const telefono_movil = formData.get("telefono_movil") as string;
    const dni_cif = formData.get("dni_cif") as string;
    const tipo = formData.get("tipo") as string;
    const razon_social = formData.get("razon_social") as string;
    const direccion_facturacion = formData.get("direccion_facturacion") as string;
    const codigo_postal = formData.get("codigo_postal") as string;
    const ciudad = formData.get("ciudad") as string;
    const provincia = formData.get("provincia") as string;

    // Comprobar los campos obligatorios
    if (
        !nombres_cliente?.trim() ||
        !apellido1_cliente?.trim() ||
        !telefono_movil?.trim() ||
        !dni_cif?.trim() ||
        !direccion_facturacion?.trim() ||
        !codigo_postal?.trim() ||
        !ciudad?.trim() ||
        !provincia?.trim()
    ) {
        return new Response("Faltan datos obligatorios", {
            status: 400,
        });
    }

    // Comprobar el tipo de cliente
    if (!["particular", "autonomo", "empresa"].includes(tipo)) {
        return new Response("Tipo de cliente no válido", {
            status: 400,
        });
    }

    // La razón social es obligatoria para empresas
    if (tipo === "empresa" && !razon_social?.trim()) {
        return new Response("La razón social es obligatoria para empresas", {
            status: 400,
        });
    }

    const sesion = await getUsuarioDesdeCookies(cookies);

    if (!sesion.user) {
        return new Response(
            sesion.error === "sin-sesion" ? "No autenticado" : "Sesión no válida",
            { status: 401 }
        );
    }

    const textQuery = `
    INSERT INTO clientes (
        pk_cliente,
        email,
        dni_cif,
        tipo,
        razon_social,
        nombres_cliente,
        apellido1_cliente,
        apellido2_cliente,
        telefono_movil,
        direccion_facturacion,
        codigo_postal,
        ciudad,
        provincia,
        rol
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
    ON CONFLICT (pk_cliente) DO UPDATE
    SET email = EXCLUDED.email,
        dni_cif = EXCLUDED.dni_cif,
        tipo = EXCLUDED.tipo,
        razon_social = EXCLUDED.razon_social,
        nombres_cliente = EXCLUDED.nombres_cliente,
        apellido1_cliente = EXCLUDED.apellido1_cliente,
        apellido2_cliente = EXCLUDED.apellido2_cliente,
        telefono_movil = EXCLUDED.telefono_movil,
        direccion_facturacion = EXCLUDED.direccion_facturacion,
        codigo_postal = EXCLUDED.codigo_postal,
        ciudad = EXCLUDED.ciudad,
        provincia = EXCLUDED.provincia
`;

    const values = [
        sesion.user.id,
        sesion.user.email,
        dni_cif,
        tipo,
        tipo === "empresa" ? razon_social.trim() : null,
        nombres_cliente,
        apellido1_cliente,
        apellido2_cliente,
        telefono_movil,
        direccion_facturacion,
        codigo_postal,
        ciudad,
        provincia,
        "cliente",
    ];

    try {
        await pool.query(textQuery, values);
    } catch (error) {
        console.error("Error al guardar el cliente:", error);
        return new Response("Error al guardar el cliente", { status: 500 });
    }

    // Redirección según el origen de navegación, validada con lista blanca
    // para evitar redirecciones abiertas.
    const volver = formData.get("volver");

    return new Response(null, {
        status: 302,
        headers: {
            Location: volver === "carrito" ? "/carrito" : "/",
        },
    });
};

   
