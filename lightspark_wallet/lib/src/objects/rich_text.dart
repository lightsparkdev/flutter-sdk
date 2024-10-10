
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class RichText {

    final String text;


    RichText(
        this.text, 
    );



static RichText fromJson(Map<String, dynamic> json) {
    return RichText(
        json["rich_text_text"],

        );

}

    static const fragment = r'''
fragment RichTextFragment on RichText {
    __typename
    rich_text_text: text
}''';

}
