import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPokemon from '@salesforce/apex/PokeApiService.getPokemon';

export default class PokemonSearch extends LightningElement {
    @track searchTerm;
    @track pokemon;
    @track error;

    handleChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearch() {

        getPokemon({ pokemonNameOrId: this.searchTerm })
            .then(response => {

                if (response.status === 'OK') {
                    this.pokemon = response.pokemon;
                    this.error = null;
                    
                    this.dispatchEvent(new CustomEvent('pokemoncaptured', {
                        detail: this.pokemon
                    }));
                    // Mostrar Toast de éxito
                    this.showToast('¡Pokémon Caught!', `You have captured ${this.pokemon.Name}.`, 'success');
                } else {
                    this.error = response.message;

                    // Mostrar Toast de error
                    this.showToast('Error', response.message, 'error');
                }
            })
            .catch(error => {
                console.error('Error in getPokemon:', error);

                this.error = error.body?.message || 'unknown error';

                // Mostrar Toast de error en caso de fallo
                this.showToast('Error', this.error, 'error');
            });
    }

    // Método para mostrar los mensajes Toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
