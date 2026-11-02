// Validación compartida de la sesión de Supabase a partir de las cookies.
// Se usa en páginas y endpoints de API que requieren usuario autenticado.

import type { AstroCookies } from "astro";
import type { User } from "@supabase/supabase-js";
import { supabase } from "./supabase";

export type ResultadoSesion =
    | { user: User; error: null }
    | { user: null; error: "sin-sesion" | "sesion-invalida" };

export async function getUsuarioDesdeCookies(
    cookies: AstroCookies
): Promise<ResultadoSesion> {
    const accessToken = cookies.get("sb-access-token")?.value;
    const refreshToken = cookies.get("sb-refresh-token")?.value;

    if (!accessToken || !refreshToken) {
        return { user: null, error: "sin-sesion" };
    }

    const { data, error } = await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken,
    });

    if (error || !data.user) {
        return { user: null, error: "sesion-invalida" };
    }

    return { user: data.user, error: null };
}
