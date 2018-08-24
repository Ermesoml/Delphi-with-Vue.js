<template>
  <div class="w3-container">
    <h2>Lista de cadastros</h2>
    <table class="w3-table-all">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nome</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="cadastro in cadastros">
          <td>{{cadastro.cadastro_id}}</td>
          <td>{{cadastro.nome}}</td>
        </tr>
      </tbody>
    </table>
    <br>
  </div>
</template>

<script>
export default {
  name: 'ListaCadastros',
  data () {
    return {
      cadastros: []
    }
  },
  methods: {
    buscarCadastros: function() {
      this.axios.get('http://localhost:9000/cadastros')
      .then(response => {
        this.cadastros = Object.assign([], response.data);
      })
      .catch(error => {
        alert('Erro ao requisitar os dados do servidor!')
      })
    }
  },
  mounted(){
    this.buscarCadastros();
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
