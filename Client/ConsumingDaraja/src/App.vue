<template>
  <div id="app">
    <!-- Top container -->
    <div class="w3-bar w3-top w3-blue w3-large" style="z-index:4">
      <button class="w3-bar-item w3-button w3-hide-large w3-hover-none w3-hover-text-light-grey" @click="w3_open();"><i class="fa fa-bars"></i>  Menu</button>
      <span class="w3-bar-item w3-right">Lista de cadastros</span>
    </div>

    <!-- Sidebar/menu -->
    <nav class="w3-sidebar w3-collapse w3-white w3-animate-left" style="z-index:3;width:300px;" id="mySidebar"><br>
      <div class="w3-container w3-row">
        <div class="w3-col s21 w3-bar">
          <span>Olá, <strong>Visitante</strong></span><br>
          <a href="#" class="w3-bar-item w3-button"><i class="fa fa-envelope"></i></a>
          <a href="#" class="w3-bar-item w3-button"><i class="fa fa-user"></i></a>
          <a href="#" class="w3-bar-item w3-button"><i class="fa fa-cog"></i></a>
        </div>
      </div>
      <hr>
      <div class="w3-container">
        <h5>Menu</h5>
      </div>
      <div class="w3-bar-block">
        <a href="#" class="w3-bar-item w3-button w3-padding-16 w3-hide-large w3-dark-grey w3-hover-black" @click="w3_close()" title="close menu"><i class="fa fa-remove fa-fw"></i>  Fechar menu</a>
        <a href="/" class="w3-bar-item w3-button w3-padding w3-blue"><i class="fa fa-users fa-fw"></i> Lista de cadastros</a>
        <br>
      </div>
    </nav>
    <div class="w3-overlay w3-hide-large w3-animate-opacity" @click="w3_close()" style="cursor:pointer" title="close side menu" id="myOverlay"></div>

    <div class="w3-main" style="margin-left:320px;margin-top:43px;">
      <router-view/>
    </div>
  </div>
</template>

<script>

export default {
  name: 'App',
  methods: {
    w3_open: function () {
      var mySidebar = document.getElementById("mySidebar");
      var overlayBg = document.getElementById("myOverlay"); 
      if (mySidebar.style.display === 'block') {
        mySidebar.style.display = 'none';
        overlayBg.style.display = "none";
      } else {
        mySidebar.style.display = 'block';
        overlayBg.style.display = "block";
      }
    },
    w3_close: function () {
      var mySidebar = document.getElementById("mySidebar");
      var overlayBg = document.getElementById("myOverlay");
      mySidebar.style.display = "none";
      overlayBg.style.display = "none";
    }
  }
}
</script>

<style>

</style>
