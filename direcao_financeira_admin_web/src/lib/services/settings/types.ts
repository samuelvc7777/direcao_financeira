export type FeedbackState = "idle" | "loading" | "success" | "error";

export interface ActionFeedback {
  state: FeedbackState;
  message?: string;
}
