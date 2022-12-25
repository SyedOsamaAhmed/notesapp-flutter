extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}


/**Stream of list of database Note we have to filter it on the basis of current condition the where clause specify test that checks the condition on individual element and then creates new stream and broadcas it */