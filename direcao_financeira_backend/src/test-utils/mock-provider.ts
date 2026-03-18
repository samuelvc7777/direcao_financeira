export function createMockProvider(provide: string | symbol | Function) {
  return {
    provide,
    useValue: {},
  };
}
