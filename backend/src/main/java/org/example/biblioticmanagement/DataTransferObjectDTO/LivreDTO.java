package org.example.biblioticmanagement.DataTransferObjectDTO;

public class LivreDTO {

    private Long id;
    private String titre;
    private String auteur;
    private String description;
    private Float prixParJour;
    private int nombreExemplaires;
    private int exemplairesDisponibles;
    private int statisticNbrEmpruntTotal;
    private String catalogue;

    public LivreDTO(Long id, String titre, String auteur, String description, Float prixParJour, int nombreExemplaires, int exemplairesDisponibles, int statisticNbrEmpruntTotal, String catalogue) {
        this.id = id;
        this.titre = titre;
        this.auteur = auteur;
        this.description = description;
        this.prixParJour = prixParJour;
        this.nombreExemplaires = nombreExemplaires;
        this.exemplairesDisponibles = exemplairesDisponibles;
        this.statisticNbrEmpruntTotal = statisticNbrEmpruntTotal;
        this.catalogue = catalogue;
    }

    public Long getId() {
        return id;
    }

    public String getTitre() {
        return titre;
    }

    public String getAuteur() {
        return auteur;
    }

    public String getDescription() {
        return description;
    }

    public Float getPrixParJour() {
        return prixParJour;
    }

    public int getNombreExemplaires() {
        return nombreExemplaires;
    }

    public int getExemplairesDisponibles() {
        return exemplairesDisponibles;
    }

    public int getStatisticNbrEmpruntTotal() {
        return statisticNbrEmpruntTotal;
    }

    public String getCatalogue() {
        return catalogue;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public void setAuteur(String auteur) {
        this.auteur = auteur;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setPrixParJour(Float prixParJour) {
        this.prixParJour = prixParJour;
    }

    public void setNombreExemplaires(int nombreExemplaires) {
        this.nombreExemplaires = nombreExemplaires;
    }

    public void setExemplairesDisponibles(int exemplairesDisponibles) {
        this.exemplairesDisponibles = exemplairesDisponibles;
    }

    public void setStatisticNbrEmpruntTotal(int statisticNbrEmpruntTotal) {
        this.statisticNbrEmpruntTotal = statisticNbrEmpruntTotal;
    }

    public void setCatalogue(String catalogue) {
        this.catalogue = catalogue;
    }
}
