import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

let browserClient: SupabaseClient | null = null;

type RequestOptions = RequestInit & {
  body?: BodyInit | null;
};

function getSupabaseClient() {
  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase nao configurado. Defina NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_ANON_KEY.");
  }

  if (!browserClient) {
    browserClient = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    });
  }

  return browserClient;
}

function getToken() {
  if (typeof window === "undefined") {
    return "";
  }

  return localStorage.getItem("token") ?? "";
}

async function parseResponse(response: Response) {
  const text = await response.text();
  const data = text ? JSON.parse(text) : null;

  if (!response.ok) {
    throw new Error(data?.message ?? "Erro ao realizar requisicao.");
  }

  return data;
}

async function requestApi(endpoint: string, options: RequestOptions = {}) {
  const token = getToken();
  const response = await fetch(`/api${endpoint}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });

  return parseResponse(response);
}

export async function signOut() {
  const { error } = await getSupabaseClient().auth.signOut();
  if (error) {
    throw new Error(error.message);
  }
}

export async function fetchApi(endpoint: string, options: RequestOptions = {}) {
  const method = (options.method ?? "GET").toUpperCase();

  if (endpoint === "/auth/login" && method === "POST") {
    const body = options.body && typeof options.body === "string" ? JSON.parse(options.body) : {};
    const { email, password } = body as { email: string; password: string };
    const supabase = getSupabaseClient();
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      throw new Error(error.message);
    }

    const token = data.session?.access_token ?? "";
    if (typeof window !== "undefined") {
      localStorage.setItem("token", token);
    }

    const user = await requestApi("/auth/me");
    return {
      access_token: token,
      user,
    };
  }

  return requestApi(endpoint, options);
}
