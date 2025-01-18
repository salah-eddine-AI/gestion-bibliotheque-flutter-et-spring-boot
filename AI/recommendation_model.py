import requests
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Récupération des données des livres à partir de l'API
def fetch_books_data():
    url = "http://localhost:8085/livre/allLivresToFeedTheModel"
    response = requests.get(url)
    return response.json()

# Traitement des données des livres et préparation du modèle
def prepare_model():
    books_data = fetch_books_data()
    
    # Combiner le titre, la description et le catalogue (genre) pour créer un champ de texte unifié
    combined_text = [
        f"{book['titre']} {book['description']} {book['catalogue']}" for book in books_data
    ]
    
    # Débogage : Vérification des premières entrées du texte combiné
    print("Exemple de texte combiné :", combined_text[:5])  # Afficher les 5 premiers titres, descriptions et genres combinés
    
    # Vectoriseur TF-IDF avec paramètres ajustés
    tfidf_vectorizer = TfidfVectorizer(
        stop_words='english',
        ngram_range=(1, 3),  # Utiliser des unigrams, bigrams et trigrams pour un meilleur contexte
        max_df=0.7,          # Exclure les mots apparaissant dans plus de 70 % des documents
        min_df=1,            # Inclure les mots apparaissant dans au moins 1 document
        max_features=1000    # Limiter le nombre de fonctionnalités pour de meilleures performances
    )
    tfidf_matrix = tfidf_vectorizer.fit_transform(combined_text)

    # Débogage : Journaliser la matrice TF-IDF pour les 5 premiers livres
    print("Matrice TF-IDF (5 premiers livres) :", tfidf_matrix[:5].toarray())

    return books_data, tfidf_matrix, tfidf_vectorizer

# Fonction pour obtenir des recommandations basées sur la requête utilisateur
def recommend_books(user_description, books_data, tfidf_matrix, tfidf_vectorizer):
    # Ajouter le contexte à la requête utilisateur pour correspondre aux données vectorisées
    user_input = f"{user_description}"  # Utiliser directement la requête utilisateur pour une correspondance plus flexible
    
    # Convertir la description utilisateur en fonctionnalités TF-IDF
    user_tfidf = tfidf_vectorizer.transform([user_input])

    # Calculer la similarité cosinus entre la requête utilisateur et toutes les descriptions de livres
    cosine_sim = cosine_similarity(user_tfidf, tfidf_matrix)

    # Débogage : Journaliser les scores de similarité cosinus
    print("Similarités cosinus :", cosine_sim)

    # Obtenir les indices des livres les plus similaires (triés par ordre décroissant)
    similar_books_indices = cosine_sim.argsort()[0, ::-1]

    # Retourner les 5 livres les plus similaires
    recommended_books = []
    for idx in similar_books_indices[:5]:
        recommended_books.append(books_data[idx])

    return recommended_books

# Point de terminaison pour gérer la requête utilisateur et retourner des recommandations
@app.route('/query', methods=['POST'])
def query_recommendation():
    data = request.json
    user_description = data.get('query', '')

    if not user_description:
        return jsonify({"error": "Aucune requête fournie"}), 400

    # Préparer le modèle et obtenir des recommandations
    books_data, tfidf_matrix, tfidf_vectorizer = prepare_model()
    recommended_books = recommend_books(user_description, books_data, tfidf_matrix, tfidf_vectorizer)

    # Retourner les livres recommandés dans la réponse
    return jsonify(recommended_books)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
