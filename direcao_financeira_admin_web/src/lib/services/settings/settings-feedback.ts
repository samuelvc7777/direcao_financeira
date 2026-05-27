import type { ActionFeedback } from "./types";

export const idleFeedback = (): ActionFeedback => ({ state: "idle" });
export const loadingFeedback = (): ActionFeedback => ({ state: "loading" });
export const successFeedback = (message: string): ActionFeedback => ({ state: "success", message });
export const errorFeedback = (message: string): ActionFeedback => ({ state: "error", message });
