public with sharing class PokeApiService {
    public class PokeResponse {
        public String message;
        public String status;
        public Pokemon__c pokemon;
    }       
        // Método para obtener la lista de todos los Pokémon en Salesforce
        @AuraEnabled(cacheable=true)
        public static List<Pokemon__c> getAllPokemons() {
            return [SELECT Name, External_ID__c, HP__c, Attack__c, Defense__c, Front_Image__c 
                    FROM Pokemon__c 
                    ORDER BY External_ID__c ASC];
        }
    
     @AuraEnabled(cacheable=true)
    public static PokeResponse getPokemon(String pokemonNameOrId) {
        PokeResponse response = new PokeResponse();
        
        // Verificar si el Pokémon ya existe en Salesforce
        List<Pokemon__c> existingPokemons = [SELECT Id, Name FROM Pokemon__c WHERE External_ID__c = :pokemonNameOrId LIMIT 1];
        if (!existingPokemons.isEmpty()) {
            response.message = 'Pokémon already captured';
            response.status = 'DuplicatedPokemon';
            response.pokemon = existingPokemons[0];
            return response;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://pokeapi.co/api/v2/pokemon/' + pokemonNameOrId);
        request.setMethod('GET');
        
        try {
            HttpResponse res = http.send(request);
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                // Convertimos `stats` a una lista correctamente
                List<Object> stats = (List<Object>) result.get('stats');
                
                // Convertimos `abilities` a una lista correctamente
                List<Object> abilities = (List<Object>) result.get('abilities');
                
                Pokemon__c newPokemon = new Pokemon__c(
                    Name = (String) result.get('name'),
                    External_ID__c = String.valueOf(result.get('id')),
                    Height__c = (Decimal) result.get('height'),
                    Weight__c = (Decimal) result.get('weight'),
                    HP__c = (Integer) ((Map<String, Object>) stats[0]).get('base_stat'),
                    Attack__c = (Integer) ((Map<String, Object>) stats[1]).get('base_stat'),
                    Defense__c = (Integer) ((Map<String, Object>) stats[2]).get('base_stat'),
                    Special_Attack__c = (Integer) ((Map<String, Object>) stats[3]).get('base_stat'),
                    Special_Defense__c = (Integer) ((Map<String, Object>) stats[4]).get('base_stat'),
                    Speed__c = (Integer) ((Map<String, Object>) stats[5]).get('base_stat'),
                    Front_Image_URL__c = (String) ((Map<String, Object>) result.get('sprites')).get('front_default'),
                    Back_Image_URL__c = (String) ((Map<String, Object>) result.get('sprites')).get('back_default')
                );
                
                insert newPokemon;
                
                // Insertar habilidades
                List<Pokemon_Ability__c> abilityRecords = new List<Pokemon_Ability__c>();
                for (Object obj : abilities) {
                    Map<String, Object> abilityEntry = (Map<String, Object>) obj;
                    Map<String, Object> ability = (Map<String, Object>) abilityEntry.get('ability');
                    
                    abilityRecords.add(new Pokemon_Ability__c(
                        Name = (String) ability.get('name'),
                        Is_Hidden__c = (Boolean) abilityEntry.get('is_hidden'),
                        Slot__c = (Integer) abilityEntry.get('slot'),
                        Pokemon__c = newPokemon.Id
                    ));
                }
                insert abilityRecords;
                
                response.message = 'Pokémon captured successfully';
                response.status = 'OK';
                response.pokemon = newPokemon;
            } else {
                response.message = 'Error retrieving Pokémon';
                response.status = 'APIError';
            }
        } catch (Exception e) {
            response.message = 'Exception: ' + e.getMessage();
            response.status = 'Error';
        }
        
        return response;
    }
}