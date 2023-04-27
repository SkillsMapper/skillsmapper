// Import fetch-mock library
import fetchMock from 'fetch-mock';

// Mock Firebase authentication
const mockFirebaseAuth = {
    currentUser: {
        getIdToken: async () => 'mock-token',
    },
};

// Mock HTML elements
const setUpHTMLFixture = () => {
    document.body.innerHTML = `
    <!-- Add the necessary HTML elements for the tests -->
  `;
};

describe('Facts app', () => {
    beforeEach(() => {
        setUpHTMLFixture();
        spyOn(window, 'fetch').and.callThrough();
        spyOn(firebase, 'auth').and.returnValue(mockFirebaseAuth);
    });

    afterEach(() => {
        fetchMock.restore();
    });

    describe('fetchFacts', () => {
        it('should successfully fetch facts and update the UI', async () => {
            // Arrange
            const mockData = {
                _embedded: {
                    factList: [
                        { id: 1, skill: 'JavaScript', level: 'learning' },
                        { id: 2, skill: 'Python', level: 'using' },
                    ],
                },
            };
            fetchMock.get('/api/facts', {
                status: 200,
                body: mockData,
                headers: { 'Content-Type': 'application/json' },
            });

            // Act
            await fetchFacts();

            // Assert
            expect(fetch).toHaveBeenCalled();
            expect($('#factsCollection').children().length).toBe(2);
        });
    });

    describe('submitFact', () => {
        // Write tests for submitFact function
    });

    describe('deleteFact', () => {
        // Write tests for deleteFact function
    });

    describe('UI interactions', () => {
        // Write tests for UI interactions like clicking buttons
    });
});
