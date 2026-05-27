import { NextRequest, NextResponse } from "next/server";

import {
  cancelSubscription,
  changePlan,
  createHelpVideo,
  createPlan,
  deleteHelpVideo,
  deletePlan,
  deleteUser,
  getDashboard,
  getCompanySettings,
  getUserById,
  listHelpVideos,
  listPlans,
  listUsers,
  renewSubscription,
  requireAdminFromToken,
  updateHelpVideo,
  updatePlan,
  updateCompanySettings,
  updateUser,
} from "@/lib/api/server";
import type { HelpVideo } from "@/lib/subscriptions";

type RouteContext = {
  params: Promise<{
    path?: string[];
  }>;
};

function getToken(request: NextRequest) {
  const header = request.headers.get("authorization") ?? "";
  return header.replace(/^Bearer\s+/i, "").trim();
}

async function getPayload(request: NextRequest) {
  const text = await request.text();
  return text ? (JSON.parse(text) as Record<string, unknown>) : {};
}

function jsonError(error: unknown, status = 400) {
  const message = error instanceof Error ? error.message : "Erro interno no painel.";
  return NextResponse.json({ message }, { status });
}

export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const token = getToken(request);
    await requireAdminFromToken(token);
    const { path = [] } = await context.params;
    const endpoint = `/${path.join("/")}`;

    if (endpoint === "/auth/me") {
      const user = await requireAdminFromToken(token);
      return NextResponse.json(user);
    }

    if (endpoint === "/user") {
      return NextResponse.json(await listUsers());
    }

    if (endpoint === "/admin/dashboard") {
      return NextResponse.json(await getDashboard());
    }

    if (endpoint === "/admin/plans") {
      return NextResponse.json(await listPlans());
    }

    if (endpoint === "/admin/help-videos") {
      return NextResponse.json(await listHelpVideos());
    }
    if (endpoint === "/admin/company-settings") {
      return NextResponse.json(await getCompanySettings());
    }

    const userMatch = endpoint.match(/^\/user\/(\d+)$/);
    if (userMatch) {
      return NextResponse.json(await getUserById(Number(userMatch[1])));
    }

    return jsonError(new Error(`Endpoint nao mapeado: GET ${endpoint}`), 404);
  } catch (error) {
    return jsonError(error, 401);
  }
}

export async function POST(request: NextRequest, context: RouteContext) {
  try {
    const token = getToken(request);
    await requireAdminFromToken(token);
    const payload = await getPayload(request);
    const { path = [] } = await context.params;
    const endpoint = `/${path.join("/")}`;

    if (endpoint === "/admin/plans") {
      return NextResponse.json(await createPlan(payload));
    }

    if (endpoint === "/admin/help-videos") {
      return NextResponse.json(await createHelpVideo(payload as Partial<HelpVideo>));
    }

    const subscriptionMatch = endpoint.match(/^\/admin\/users\/(\d+)\/subscription\/(change-plan|cancel|renew)$/);
    if (subscriptionMatch) {
      const userId = Number(subscriptionMatch[1]);
      const action = subscriptionMatch[2];

      if (action === "change-plan") {
        return NextResponse.json(await changePlan(userId, Number(payload.planId)));
      }

      if (action === "cancel") {
        return NextResponse.json(await cancelSubscription(userId));
      }

      return NextResponse.json(await renewSubscription(userId, payload.autoRenew as boolean | undefined));
    }

    return jsonError(new Error(`Endpoint nao mapeado: POST ${endpoint}`), 404);
  } catch (error) {
    return jsonError(error, 400);
  }
}

export async function PATCH(request: NextRequest, context: RouteContext) {
  try {
    const token = getToken(request);
    await requireAdminFromToken(token);
    const payload = await getPayload(request);
    const { path = [] } = await context.params;
    const endpoint = `/${path.join("/")}`;

    const userMatch = endpoint.match(/^\/user\/(\d+)$/);
    if (userMatch) {
      return NextResponse.json(await updateUser(Number(userMatch[1]), payload));
    }

    const planMatch = endpoint.match(/^\/admin\/plans\/(\d+)$/);
    if (planMatch) {
      return NextResponse.json(await updatePlan(Number(planMatch[1]), payload));
    }

    const helpVideoMatch = endpoint.match(/^\/admin\/help-videos\/(\d+)$/);
    if (helpVideoMatch) {
      return NextResponse.json(await updateHelpVideo(Number(helpVideoMatch[1]), payload as Partial<HelpVideo>));
    }
    if (endpoint === "/admin/company-settings") {
      const rawGoogleApiKey = String(payload.googleApiKey ?? "");
      const googleApiKey = rawGoogleApiKey.trim();
      if (!googleApiKey) {
        throw new Error("Informe uma API Google valida.");
      }

      return NextResponse.json(
        await updateCompanySettings({
          googleApiKey,
        }),
      );
    }

    return jsonError(new Error(`Endpoint nao mapeado: PATCH ${endpoint}`), 404);
  } catch (error) {
    return jsonError(error, 400);
  }
}

export async function DELETE(request: NextRequest, context: RouteContext) {
  try {
    const token = getToken(request);
    await requireAdminFromToken(token);
    const { path = [] } = await context.params;
    const endpoint = `/${path.join("/")}`;

    const userMatch = endpoint.match(/^\/user\/(\d+)$/);
    if (userMatch) {
      return NextResponse.json(await deleteUser(Number(userMatch[1])));
    }

    const planMatch = endpoint.match(/^\/admin\/plans\/(\d+)$/);
    if (planMatch) {
      return NextResponse.json(await deletePlan(Number(planMatch[1])));
    }

    const helpVideoMatch = endpoint.match(/^\/admin\/help-videos\/(\d+)$/);
    if (helpVideoMatch) {
      return NextResponse.json(await deleteHelpVideo(Number(helpVideoMatch[1])));
    }

    return jsonError(new Error(`Endpoint nao mapeado: DELETE ${endpoint}`), 404);
  } catch (error) {
    return jsonError(error, 400);
  }
}
