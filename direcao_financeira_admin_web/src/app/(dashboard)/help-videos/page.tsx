'use client';

import { FormEvent, ReactNode, useCallback, useEffect, useMemo, useState } from 'react';
import {
  AlertCircle,
  CheckCircle2,
  Edit2,
  Loader2,
  Plus,
  Save,
  Trash2,
} from 'lucide-react';

import { fetchApi } from '@/lib/api/client';
import type { HelpVideo } from '@/lib/subscriptions';

type FormState = {
  id?: number;
  title: string;
  description: string;
  youtubeVideoId: string;
  category: string;
  durationLabel: string;
  thumbnailUrl: string;
  isFeatured: boolean;
  isActive: boolean;
  sortOrder: number;
};

type Feedback = {
  type: 'success' | 'error';
  message: string;
};

const emptyForm: FormState = {
  title: '',
  description: '',
  youtubeVideoId: '',
  category: '',
  durationLabel: '',
  thumbnailUrl: '',
  isFeatured: false,
  isActive: true,
  sortOrder: 0,
};

const inputClass =
  'w-full rounded-2xl border border-slate-700/70 bg-slate-950/35 px-4 py-3.5 text-sm font-semibold text-white outline-none transition-all placeholder:text-slate-500 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10';

function getErrorMessage(error: unknown, fallback: string) {
  return error instanceof Error ? error.message : fallback;
}

function normalizeYouTubeVideoId(value: string) {
  const raw = value.trim();
  if (!raw) {
    return '';
  }

  try {
    const url = new URL(raw);
    if (url.hostname.includes('youtu.be')) {
      return url.pathname.replace('/', '').trim();
    }

    const watchId = url.searchParams.get('v');
    if (watchId) {
      return watchId.trim();
    }

    const segments = url.pathname.split('/').filter(Boolean);
    const embedIndex = segments.indexOf('embed');
    if (embedIndex >= 0 && segments[embedIndex + 1]) {
      return segments[embedIndex + 1].trim();
    }
  } catch {
    return raw;
  }

  return raw;
}

function videoToForm(video: HelpVideo): FormState {
  return {
    id: video.id,
    title: video.title,
    description: video.description,
    youtubeVideoId: video.videoUrl || video.youtubeVideoId,
    category: video.category,
    durationLabel: video.durationLabel,
    thumbnailUrl: video.thumbnailUrl,
    isFeatured: video.isFeatured,
    isActive: video.isActive,
    sortOrder: video.sortOrder,
  };
}

export default function HelpVideosPage() {
  const [videos, setVideos] = useState<HelpVideo[]>([]);
  const [form, setForm] = useState<FormState>(emptyForm);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [feedback, setFeedback] = useState<Feedback | null>(null);

  const activeCount = useMemo(
    () => videos.filter((video) => video.isActive).length,
    [videos],
  );

  const loadVideos = useCallback(async () => {
    setIsLoading(true);
    setFeedback(null);

    try {
      const response = await fetchApi('/admin/help-videos');
      setVideos(Array.isArray(response) ? (response as HelpVideo[]) : []);
    } catch (error) {
      setFeedback({
        type: 'error',
        message: getErrorMessage(error, 'Nao foi possivel carregar os videos.'),
      });
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadVideos();
  }, [loadVideos]);

  const openNewForm = () => {
    setForm(emptyForm);
    setFeedback(null);
    setIsFormOpen(true);
  };

  const openEditForm = (video: HelpVideo) => {
    setForm(videoToForm(video));
    setFeedback(null);
    setIsFormOpen(true);
  };

  const closeForm = () => {
    setForm(emptyForm);
    setFeedback(null);
    setIsFormOpen(false);
  };

  const saveVideo = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsSaving(true);
    setFeedback(null);

    const normalizedId = normalizeYouTubeVideoId(form.youtubeVideoId);
    const payload = {
      ...form,
      youtubeVideoId: normalizedId,
      videoUrl: form.youtubeVideoId.trim().startsWith('http')
        ? form.youtubeVideoId.trim()
        : `https://www.youtube.com/watch?v=${normalizedId}`,
      sortOrder: Number(form.sortOrder || 0),
    };

    try {
      if (form.id) {
        await fetchApi(`/admin/help-videos/${form.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload),
        });
      } else {
        await fetchApi('/admin/help-videos', {
          method: 'POST',
          body: JSON.stringify(payload),
        });
      }

      setFeedback({
        type: 'success',
        message: form.id ? 'Video atualizado com sucesso.' : 'Video criado com sucesso.',
      });
      closeForm();
      await loadVideos();
    } catch (error) {
      setFeedback({
        type: 'error',
        message: getErrorMessage(error, 'Nao foi possivel salvar o video.'),
      });
    } finally {
      setIsSaving(false);
    }
  };

  const deleteVideo = async (video: HelpVideo) => {
    if (!confirm(`Excluir o video "${video.title}"?`)) {
      return;
    }

    try {
      await fetchApi(`/admin/help-videos/${video.id}`, { method: 'DELETE' });
      await loadVideos();
    } catch (error) {
      setFeedback({
        type: 'error',
        message: getErrorMessage(error, 'Nao foi possivel excluir o video.'),
      });
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-[70vh] items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="h-10 w-10 animate-spin text-indigo-500" />
          <p className="text-sm font-medium text-slate-500">Carregando videos...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-full bg-[#030712] px-6 py-9 sm:px-10 lg:px-10">
      <div className="mx-auto max-w-[1552px] space-y-8">
        {feedback && (
          <div
            className={`flex items-center gap-3 rounded-2xl border p-4 ${
              feedback.type === 'success'
                ? 'border-emerald-500/20 bg-emerald-500/10 text-emerald-300'
                : 'border-red-500/20 bg-red-500/10 text-red-300'
            }`}
          >
            {feedback.type === 'success' ? (
              <CheckCircle2 className="h-5 w-5 shrink-0" />
            ) : (
              <AlertCircle className="h-5 w-5 shrink-0" />
            )}
            <p className="text-sm font-semibold">{feedback.message}</p>
          </div>
        )}

        {isFormOpen ? (
          <VideoForm
            form={form}
            isSaving={isSaving}
            onCancel={closeForm}
            onChange={setForm}
            onSubmit={saveVideo}
          />
        ) : (
          <VideoLibrary
            videos={videos}
            activeCount={activeCount}
            onCreate={openNewForm}
            onEdit={openEditForm}
            onDelete={deleteVideo}
          />
        )}
      </div>
    </div>
  );
}

function VideoForm({
  form,
  isSaving,
  onCancel,
  onChange,
  onSubmit,
}: {
  form: FormState;
  isSaving: boolean;
  onCancel: () => void;
  onChange: (value: FormState | ((current: FormState) => FormState)) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  return (
    <div className="max-w-3xl">
      <p className="mb-4 text-xs font-black uppercase tracking-[0.45em] text-indigo-400">
        {form.id ? 'Editar video' : 'Novo video'}
      </p>
      <h1 className="text-3xl font-black tracking-tight text-white">
        {form.id ? 'Editar video' : 'Adicionar video'}
      </h1>
      <p className="mt-3 text-sm font-medium text-slate-400">
        Informe nome, descricao e link. Thumbnail e identificador do YouTube sao derivados automaticamente.
      </p>

      <form
        onSubmit={onSubmit}
        className="mt-8 rounded-2xl border border-slate-700/70 bg-slate-900/80 p-6 shadow-2xl shadow-black/20 sm:p-7"
      >
        <div className="space-y-7">
          <Field label="Nome">
            <input
              value={form.title}
              onChange={(event) => onChange((current) => ({ ...current, title: event.target.value }))}
              className={inputClass}
              placeholder="Video de boas-vindas"
            />
          </Field>

          <Field label="Descricao">
            <textarea
              value={form.description}
              onChange={(event) => onChange((current) => ({ ...current, description: event.target.value }))}
              className={`${inputClass} min-h-32 resize-y`}
              placeholder="Explique o que o usuario aprende neste video."
            />
          </Field>

          <Field label="Link do video">
            <input
              value={form.youtubeVideoId}
              onChange={(event) => onChange((current) => ({ ...current, youtubeVideoId: event.target.value }))}
              className={inputClass}
              placeholder="https://www.youtube.com/watch?v=..."
            />
          </Field>

          <Field label="Ordem">
            <input
              type="number"
              min={0}
              value={form.sortOrder}
              onChange={(event) => onChange((current) => ({ ...current, sortOrder: Number(event.target.value) }))}
              className="w-80 max-w-full rounded-2xl border border-slate-700/70 bg-slate-950/35 px-4 py-3.5 text-sm font-semibold text-white outline-none transition-all focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10"
            />
          </Field>

          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <CheckTile
              label="Ativo"
              checked={form.isActive}
              onChange={(checked) => onChange((current) => ({ ...current, isActive: checked }))}
            />
            <CheckTile
              label="Destaque"
              checked={form.isFeatured}
              onChange={(checked) => onChange((current) => ({ ...current, isFeatured: checked }))}
            />
          </div>
        </div>

        <div className="mt-8 flex items-center justify-end gap-6">
          <button
            type="button"
            onClick={onCancel}
            className="text-sm font-semibold text-slate-500 transition-colors hover:text-slate-300"
          >
            Cancelar
          </button>
          <button
            type="submit"
            disabled={isSaving}
            className="inline-flex items-center gap-2 rounded-2xl bg-indigo-600 px-6 py-3.5 text-sm font-bold text-white shadow-xl shadow-indigo-500/25 transition-all hover:bg-indigo-500 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
          >
            {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            Salvar
          </button>
        </div>
      </form>
    </div>
  );
}

function VideoLibrary({
  videos,
  activeCount,
  onCreate,
  onEdit,
  onDelete,
}: {
  videos: HelpVideo[];
  activeCount: number;
  onCreate: () => void;
  onEdit: (video: HelpVideo) => void;
  onDelete: (video: HelpVideo) => void;
}) {
  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-3xl font-black tracking-tight text-white">Videos</h1>
          <p className="mt-3 text-sm font-medium text-slate-400">
            Gerencie os videos exibidos na tela de Ajuda do app.
          </p>
        </div>
        <button
          type="button"
          onClick={onCreate}
          className="inline-flex items-center justify-center gap-2 rounded-2xl bg-indigo-600 px-6 py-3.5 text-sm font-bold text-white shadow-xl shadow-indigo-500/25 transition-all hover:bg-indigo-500 active:scale-[0.98]"
        >
          <Plus className="h-5 w-5" />
          Novo video
        </button>
      </div>

      <section className="overflow-hidden rounded-2xl border border-slate-700/70 bg-slate-900/80">
        <div className="border-b border-slate-700/70 px-6 py-7">
          <h2 className="text-lg font-black text-white">Biblioteca</h2>
          <p className="mt-1 text-sm font-medium text-slate-400">
            {activeCount} ativo(s) de {videos.length} cadastrado(s)
          </p>
        </div>

        {videos.length === 0 ? (
          <div className="px-6 py-12 text-center text-sm font-semibold text-slate-500">
            Nenhum video cadastrado.
          </div>
        ) : (
          <div className="divide-y divide-slate-700/70">
            {videos.map((video) => (
              <article key={video.id} className="flex items-center gap-4 px-5 py-5">
                <div className="relative h-[72px] w-32 shrink-0 overflow-hidden rounded-xl bg-slate-950">
                  <span
                    className="absolute inset-0 bg-cover bg-center"
                    style={{
                      backgroundImage: `url(${video.thumbnailUrl || `https://img.youtube.com/vi/${video.youtubeVideoId}/hqdefault.jpg`})`,
                    }}
                  />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-3">
                    <h3 className="truncate text-sm font-black text-white">{video.title}</h3>
                    <span
                      className={`rounded-full border px-3 py-1 text-[10px] font-black uppercase tracking-wider ${
                        video.isActive
                          ? 'border-emerald-400/30 bg-emerald-500/10 text-emerald-400'
                          : 'border-slate-600 bg-slate-800 text-slate-400'
                      }`}
                    >
                      {video.isActive ? 'Ativo' : 'Oculto'}
                    </span>
                    {video.isFeatured && (
                      <span className="rounded-full border border-amber-400/30 bg-amber-500/10 px-3 py-1 text-[10px] font-black uppercase tracking-wider text-amber-400">
                        Destaque
                      </span>
                    )}
                  </div>
                  <p className="mt-2 line-clamp-1 text-sm font-medium text-slate-400">{video.description}</p>
                  <p className="mt-2 text-xs font-bold text-slate-500">ordem {video.sortOrder}</p>
                </div>
                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => onEdit(video)}
                    className="rounded-xl bg-indigo-500/10 p-3 text-indigo-300 transition-colors hover:bg-indigo-500/20"
                    title="Editar"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => onDelete(video)}
                    className="rounded-xl bg-red-500/10 p-3 text-red-400 transition-colors hover:bg-red-500/20"
                    title="Excluir"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <label className="block space-y-3">
      <span className="ml-1 text-xs font-black uppercase tracking-[0.18em] text-slate-400">{label}</span>
      {children}
    </label>
  );
}

function CheckTile({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
}) {
  return (
    <button
      type="button"
      onClick={() => onChange(!checked)}
      className="flex items-center gap-3 rounded-2xl border border-slate-700/70 bg-slate-950/30 px-4 py-4 text-left"
    >
      <span
        className={`flex h-4 w-4 items-center justify-center rounded-[4px] border text-[10px] ${
          checked ? 'border-red-500 bg-red-500 text-white' : 'border-slate-500 bg-slate-700 text-transparent'
        }`}
      >
        ✓
      </span>
      <span className="text-sm font-black text-white">{label}</span>
    </button>
  );
}
