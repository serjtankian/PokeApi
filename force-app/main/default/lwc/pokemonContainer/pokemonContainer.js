import { LightningElement } from 'lwc';

export default class PokemonContainer extends LightningElement {
    handlePokemonCaptured(event) {
        // Obtener el nuevo Pokémon desde el evento
        const newPokemon = event.detail;
        
        this.template.querySelector('c-pokemon-list').refreshList();
    }
}