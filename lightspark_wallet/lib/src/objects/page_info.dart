// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

/// This is an object representing information about a page returned by the Lightspark API. For more information, please see the “Pagination” section of our API docs for more information about its usage.
class PageInfo {
  final bool? hasNextPage;

  final bool? hasPreviousPage;

  final String? startCursor;

  final String? endCursor;

  PageInfo(
    this.hasNextPage,
    this.hasPreviousPage,
    this.startCursor,
    this.endCursor,
  );

  static PageInfo fromJson(Map<String, dynamic> json) {
    return PageInfo(
      json['page_info_has_next_page'],
      json['page_info_has_previous_page'],
      json['page_info_start_cursor'],
      json['page_info_end_cursor'],
    );
  }

  static const fragment = r'''
fragment PageInfoFragment on PageInfo {
    __typename
    page_info_has_next_page: has_next_page
    page_info_has_previous_page: has_previous_page
    page_info_start_cursor: start_cursor
    page_info_end_cursor: end_cursor
}''';
}
