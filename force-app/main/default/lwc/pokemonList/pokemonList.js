import { LightningElement, track, api } from 'lwc';
import getAllPokemons from '@salesforce/apex/PokeApiService.getAllPokemons';

export default class PokemonList extends LightningElement {
    @track pokemons = [];
    @track error;

    connectedCallback() {
        this.fetchPokemons();
    }

    fetchPokemons() {
        getAllPokemons()
            .then(result => {
                this.pokemons = [...result]; 
                this.error = undefined;
            })
            .catch(error => {
                console.error(' Error fetching Pokémon:', error);
                this.error = 'Error loading Pokémon data.';
                this.pokemons = [];
            });
    }

    @api refreshList() {
        console.log(' Refreshing the Pokémon list...');
        this.fetchPokemons(); 
    }
}
