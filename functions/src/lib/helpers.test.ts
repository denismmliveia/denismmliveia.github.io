jest.mock('firebase-admin', () => ({
  firestore: jest.fn(() => ({
    collection: jest.fn(),
    batch: jest.fn(),
  })),
  storage: jest.fn(() => ({ bucket: jest.fn() })),
  initializeApp: jest.fn(),
}));

// Integration-style: we test the module loads without errors
describe('helpers', () => {
  test('module imports without error', async () => {
    const { createMemories, cleanupPhotos } = await import('./helpers');
    expect(typeof createMemories).toBe('function');
    expect(typeof cleanupPhotos).toBe('function');
  });
});
