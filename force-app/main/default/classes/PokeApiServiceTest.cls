@isTest
private class PokeApiServiceTest {
    
    // Mock class for HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // Simulated PokéAPI response
            String jsonResponse = '{'
                + '"id": 25,'
                + '"name": "pikachu",'
                + '"height": 4,'
                + '"weight": 60,'
                + '"stats": ['
                + '    {"base_stat": 35},'
                + '    {"base_stat": 55},'
                + '    {"base_stat": 40},'
                + '    {"base_stat": 50},'
                + '    {"base_stat": 50},'
                + '    {"base_stat": 90}'
                + '],'
                + '"sprites": {'
                + '    "front_default": "https://example.com/front.png",'
                + '    "back_default": "https://example.com/back.png"'
                + '},'
                + '"abilities": ['
                + '    {"ability": {"name": "static"}, "is_hidden": false, "slot": 1},'
                + '    {"ability": {"name": "lightning-rod"}, "is_hidden": true, "slot": 3}'
                + ']'
                + '}';
            
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetPokemon_NewEntry() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Call method
        Test.startTest();
        PokeApiService.PokeResponse response = PokeApiService.getPokemon('pikachu');
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals('OK', response.status, 'Status should be OK');
        System.assertEquals('pikachu', response.pokemon.Name, 'Name should be Pikachu');

        // Verify the Pokémon was created
        List<Pokemon__c> createdPokemons = [SELECT Name, External_ID__c FROM Pokemon__c WHERE Name = 'pikachu'];
        System.assertEquals(1, createdPokemons.size(), 'One Pokémon should be created');
        System.assertEquals('25', createdPokemons[0].External_ID__c, 'External ID should be 25');
    }

    @isTest
    static void testGetPokemon_DuplicateEntry() {
        // Create an existing Pokémon
        Pokemon__c existingPokemon = new Pokemon__c(Name = 'pikachu', External_ID__c = '25');
        insert existingPokemon;

        // Call method again for the same Pokémon
        Test.startTest();
        PokeApiService.PokeResponse response = PokeApiService.getPokemon('pikachu');
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals('DuplicatedPokemon', response.status, 'Should return duplicate status');
    }

 
    @isTest
    static void testGetAllPokemons() {
        // Insert test data
        List<Pokemon__c> testPokemons = new List<Pokemon__c>{
            new Pokemon__c(Name = 'bulbasaur', External_ID__c = '1', HP__c = 45, Attack__c = 49, Defense__c = 49),
            new Pokemon__c(Name = 'charmander', External_ID__c = '4', HP__c = 39, Attack__c = 52, Defense__c = 43)
        };
        insert testPokemons;

        // Call method
        Test.startTest();
        List<Pokemon__c> pokemons = PokeApiService.getAllPokemons();
        Test.stopTest();

        // Assertions
        System.assertEquals(2, pokemons.size(), 'Should return exactly 2 Pokémon');
    }
}