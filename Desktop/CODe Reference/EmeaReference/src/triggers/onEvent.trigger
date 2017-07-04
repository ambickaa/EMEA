trigger onEvent on Event (before insert, before update) {

    new Triggers()

    .bind(Triggers.Evt.beforeinsert, new TriggerEventAccountVisited())
    .bind(Triggers.Evt.beforeupdate, new TriggerEventAccountVisited())

    .manage();
}