cat('
<style>
/* Largeur du contenu principal */
body, .main-container {
  max-width: 95%;
  margin: 0 auto;
  font-size: 1.05rem;
}

/* Fixer et styliser la bannière */
.header-bar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  background-color: white;
  color: #337ab7; /* couleur du thème cerulean */
  display: flex;
  align-items: center;
  padding: 10px 20px;
  z-index: 9999;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  font-size: 22px;
  font-weight: bold;
}

/* Logo à gauche */
.header-bar img {
  height: 45px;
  margin-right: 15px;
}

/* Texte à gauche du logo */
.header-text {
  text-align: left;
}

/* Décalage du haut de page pour éviter que la bannière cache le contenu */
body {
  padding-top: 70px;
}

/* Responsive */
@media (max-width: 768px) {
  .header-bar {
    font-size: 18px;
    padding: 8px 10px;
  }
  .header-bar img {
    height: 35px;
    margin-right: 10px;
  }
}
</style>

<div class="header-bar">
  <img src="images/cropped-restreco_logo-1.jpg" alt="Logo" />
  <div class="header-text">Restoring Resilient Ecosystems</div>
</div>
')