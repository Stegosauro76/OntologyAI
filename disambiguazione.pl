% Definizione dei significati
significato(banco, significato1, "un luogo dove persone svolgono operazioni finanziarie").
significato(banco, significato2, "un mobile per sedersi").
significato(banco, significato3, "un banco di scuola").
significato(banco, significato4, "un banco di pesci").  % Nuovo significato

significato(cane, significatoC1, "un animale domestico").
significato(cane, significatoC2, "una persona maleducata").
significato(cane, significatoC3, "un animale da compagnia").

% Frequenze per significati BANCO
frequenza(significato1, 2).
frequenza(significato2, 5).
frequenza(significato3, 10).
frequenza(significato4, 3).
% Frequenza per significati CANE

frequenza(significatoC1, 4).
frequenza(significatoC2, 6).
frequenza(significatoC3, 4).

frequenza(significatoC3, 6).
% Funzione per calcolare la similarità di Jaccard
similarita_jaccard(S1, S2, Similarita) :-
    significato(_, S1, Testo1),
    significato(_, S2, Testo2),
    split_string(Testo1, " ", "", Parole1),
    split_string(Testo2, " ", "", Parole2),
    list_to_set(Parole1, Set1),
    list_to_set(Parole2, Set2),
    intersection(Set1, Set2, Intersezione),
    union(Set1, Set2, Unione),
    length(Intersezione, IntersezioneCount),
    length(Unione, UnioneCount),
    (UnioneCount > 0 ->
        Similarita is IntersezioneCount / UnioneCount
    ;
        Similarita is 0
    ).

% Algoritmo WSD
esegui_algoritmo_wsd(Parola, Significati) :-
    findall(S, significato(Parola, S, _), Significati).

% Calcolo del punteggio
calcola_punteggio(Significato, Punteggio) :-
    frequenza(Significato, Frequenza),
    findall(Similarita, (
        significato(_, AltroSignificato, _),
        AltroSignificato \= Significato,
        similarita_jaccard(Significato, AltroSignificato, Similarita),
        Similarita > 0.0
    ), SimilaritaList),
    length(SimilaritaList, NumeroSimilari),
    Punteggio is Frequenza + NumeroSimilari.

% Clustering dei significati
esegui_clustering(Significati, SignificatiClustering) :-
    findall(Gruppo, (
        member(S1, Significati),
        findall(S2, (
            member(S2, Significati),
            S1 \= S2,
            similarita_jaccard(S1, S2, Similarity),
            Similarity > 0.0
        ), Gruppo),
        list_to_set(Gruppo, GruppoSet),
        GruppoSet \= []
    ), SignificatiClustering).

% Selezione del significato migliore
seleziona_significato_migliore(SignificatiClustering, SignificatoScelto, MigliorPunteggio) :-
    findall(Punteggio-Significato, (
        member(Gruppo, SignificatiClustering),
        member(Significato, Gruppo),
        calcola_punteggio(Significato, Punteggio)
    ), Punteggi),
    sort(Punteggi, SortedPunteggi),
    reverse(SortedPunteggi, [MigliorPunteggio-SignificatoScelto | _]),
    significato(_, SignificatoScelto, SignificatoTesto),
    format('Significato scelto: "~w"~n', [SignificatoTesto]).

% Funzione principale per la disambiguazione
% Funzione principale per la disambiguazione
disambiguazione( Parola, SignificatoFinale) :-
    esegui_algoritmo_wsd(Parola, Significati),
    esegui_clustering(Significati, SignificatiClustering),
    seleziona_significato_migliore(SignificatiClustering, SignificatoFinale, _).

% Esempio di utilizzo
% Puoi eseguire la seguente query per testare il codice:
% ?- disambiguazione(banco, Significato).