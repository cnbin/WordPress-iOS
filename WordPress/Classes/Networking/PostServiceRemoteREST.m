#import "PostServiceRemoteREST.h"
#import "WordPressComApi.h"
#import "BasePost.h"
#import "Blog.h"
#import "DisplayableImageHelper.h"
#import "RemotePost.h"
#import "RemotePostCategory.h"
#import "NSDate+WordPressJSON.h"

@implementation PostServiceRemoteREST

- (void)getPostWithID:(NSNumber *)postID
              forBlog:(Blog *)blog
              success:(void (^)(RemotePost *post))success
              failure:(void (^)(NSError *))failure
{
    NSParameterAssert(postID);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/%@", blog.dotComID, postID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    NSDictionary *parameters = @{ @"context": @"edit" };
    
    [self.api GET:requestUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  success([self remotePostFromJSONDictionary:responseObject]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)getPostsOfType:(NSString *)postType
               forBlog:(Blog *)blog
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure
{
    [self getPostsOfType:postType forBlog:blog options:nil success:success failure:failure];
}

- (void)getPostsOfType:(NSString *)postType
               forBlog:(Blog *)blog
               options:(NSDictionary *)options
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure
{
    NSParameterAssert([postType isKindOfClass:[NSString class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts", blog.dotComID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    NSDictionary *parameters = @{
                                 @"status": @"any,trash",
                                 @"context": @"edit",
                                 @"number": @40,
                                 @"type": postType,
                                 };
    if (options) {
        NSMutableDictionary *mutableParameters = [parameters mutableCopy];
        [mutableParameters addEntriesFromDictionary:options];
        parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    }
    [self.api GET:requestUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  success([self remotePostsFromJSONArray:responseObject[@"posts"]]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)createPost:(RemotePost *)post
           forBlog:(Blog *)blog
           success:(void (^)(RemotePost *))success
           failure:(void (^)(NSError *))failure
{
    NSParameterAssert([post isKindOfClass:[RemotePost class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/new?context=edit", blog.dotComID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    NSDictionary *parameters = [self parametersWithRemotePost:post];

    [self.api POST:requestUrl
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               RemotePost *post = [self remotePostFromJSONDictionary:responseObject];
               if (success) {
                   success(post);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)updatePost:(RemotePost *)post
           forBlog:(Blog *)blog
           success:(void (^)(RemotePost *))success
           failure:(void (^)(NSError *))failure
{
    NSParameterAssert([post isKindOfClass:[RemotePost class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/%@?context=edit", blog.dotComID, post.postID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    NSDictionary *parameters = [self parametersWithRemotePost:post];

    [self.api POST:requestUrl
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               RemotePost *post = [self remotePostFromJSONDictionary:responseObject];
               if (success) {
                   success(post);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)deletePost:(RemotePost *)post
           forBlog:(Blog *)blog
           success:(void (^)())success
           failure:(void (^)(NSError *))failure
{
    NSParameterAssert([post isKindOfClass:[RemotePost class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/%@/delete", blog.dotComID, post.postID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    [self.api POST:requestUrl
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (success) {
                   success();
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)trashPost:(RemotePost *)post
          forBlog:(Blog *)blog
          success:(void (^)(RemotePost *))success
          failure:(void (^)(NSError *))failure
{
    NSParameterAssert([post isKindOfClass:[RemotePost class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/%@/delete", blog.dotComID, post.postID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    [self.api POST:requestUrl
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               RemotePost *post = [self remotePostFromJSONDictionary:responseObject];
               if (success) {
                   success(post);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)restorePost:(RemotePost *)post
            forBlog:(Blog *)blog
            success:(void (^)(RemotePost *))success
            failure:(void (^)(NSError *))failure
{
    NSParameterAssert([post isKindOfClass:[RemotePost class]]);
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/%@/restore", blog.dotComID, post.postID];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    [self.api POST:requestUrl
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               RemotePost *post = [self remotePostFromJSONDictionary:responseObject];
               if (success) {
                   success(post);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}


#pragma mark - Private methods

- (NSArray *)remotePostsFromJSONArray:(NSArray *)jsonPosts {
    return [jsonPosts wp_map:^id(NSDictionary *jsonPost) {
        return [self remotePostFromJSONDictionary:jsonPost];
    }];
}

- (RemotePost *)remotePostFromJSONDictionary:(NSDictionary *)jsonPost {
    RemotePost *post = [RemotePost new];
    post.postID = jsonPost[@"ID"];
    post.siteID = jsonPost[@"site_ID"];
    post.authorAvatarURL = jsonPost[@"author"][@"avatar_URL"];
    post.authorDisplayName = jsonPost[@"author"][@"name"];
    post.authorEmail = [jsonPost[@"author"] stringForKey:@"email"];
    post.authorURL = jsonPost[@"author"][@"URL"];
    post.authorID = [jsonPost numberForKeyPath:@"author.ID"];
    post.date = [NSDate dateWithWordPressComJSONString:jsonPost[@"date"]];
    post.title = jsonPost[@"title"];
    post.URL = [NSURL URLWithString:jsonPost[@"URL"]];
    post.shortURL = [NSURL URLWithString:jsonPost[@"short_URL"]];
    post.content = jsonPost[@"content"];
    post.excerpt = jsonPost[@"excerpt"];
    post.slug = jsonPost[@"slug"];
    post.status = jsonPost[@"status"];
    post.password = jsonPost[@"password"];
    if ([post.password isEmpty]) {
        post.password = nil;
    }
    post.parentID = [jsonPost numberForKeyPath:@"parent.ID"];
    // post_thumbnail can be null, which will transform to NSNull, so we need to add the extra check
    NSDictionary *postThumbnail = [jsonPost dictionaryForKey:@"post_thumbnail"];
    post.postThumbnailID = [postThumbnail numberForKey:@"ID"];
    post.postThumbnailPath = [postThumbnail stringForKeyPath:@"URL"];
    post.type = jsonPost[@"type"];
    post.format = jsonPost[@"format"];

    post.commentCount = [jsonPost numberForKeyPath:@"discussion.comment_count"] ?: @0;
    post.likeCount = [jsonPost numberForKeyPath:@"like_count"] ?: @0;

    // FIXME: remove conversion once API is fixed #38-io
    // metadata should always be an array but it's returning false when there are no custom fields
    post.metadata = [jsonPost arrayForKey:@"metadata"];
    // Or even worse, in some cases (Jetpack sites?) is an array containing false
    post.metadata = [post.metadata filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[NSDictionary class]];
    }]];
    // post.metadata = jsonPost[@"metadata"];

    NSDictionary *categories = jsonPost[@"categories"];
    if (categories) {
        post.categories = [self remoteCategoriesFromJSONArray:[categories allValues]];
    }
    post.tags = [self tagNamesFromJSONDictionary:jsonPost[@"tags"]];

    // Pick an image to use for display
    if (post.postThumbnailPath) {
        post.pathForDisplayImage = post.postThumbnailPath;
    } else {
        // check attachments for a suitable image
        post.pathForDisplayImage = [DisplayableImageHelper searchPostAttachmentsForImageToDisplay:[jsonPost dictionaryForKey:@"attachments"]];

        // parse contents for a suitable image
        if (!post.pathForDisplayImage) {
            post.pathForDisplayImage = [DisplayableImageHelper searchPostContentForImageToDisplay:post.content];
        }
    }

    return post;
}

- (NSDictionary *)parametersWithRemotePost:(RemotePost *)post
{
    NSParameterAssert(post.title != nil);
    NSParameterAssert(post.content != nil);
    BOOL existingPost = ([post.postID longLongValue] > 0);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (post.title) {
        parameters[@"title"] = post.title;
    } else {
        parameters[@"title"] = @"";
    }
    
    parameters[@"content"] = post.content;
    parameters[@"password"] = post.password ? post.password : @"";
    parameters[@"type"] = post.type;

    if (post.date) {
        parameters[@"date"] = [post.date WordPressComJSONString];
    } else if (existingPost) {
        parameters[@"date"] = [[NSDate date] WordPressComJSONString];
    }
    if (post.excerpt) {
        parameters[@"excerpt"] = post.excerpt;
    }
    if (post.slug) {
        parameters[@"slug"] = post.slug;
    }
    if (post.parentID) {
        parameters[@"parent"] = post.parentID;
    }

    if (post.categories) {
        parameters[@"categories"] = [post.categories valueForKey:@"categoryID"];
    }
    if (post.tags) {
        parameters[@"tags"] = post.tags;
    }
    if (post.format) {
        parameters[@"format"] = post.format;
    }
    parameters[@"featured_image"] = post.postThumbnailID ? [post.postThumbnailID stringValue] : @"";
    parameters[@"metadata"] = [self metadataForPost:post];

    // Scheduled posts need to sync with a status of 'publish'.
    // Passing a status of 'future' will set the post status to 'draft'
    // This is an apparent inconsistency in the API as 'future' should
    // be a valid status.
    if ([post.status isEqualToString:PostStatusScheduled]) {
        post.status = PostStatusPublish;
    }
    parameters[@"status"] = post.status;

    // Test what happens for nil and not present values
    return [NSDictionary dictionaryWithDictionary:parameters];
}

- (NSArray *)metadataForPost:(RemotePost *)post {
    return [post.metadata wp_map:^id(NSDictionary *meta) {
        NSNumber *metaID = [meta objectForKey:@"id"];
        NSString *metaValue = [meta objectForKey:@"value"];
        NSString *operation = @"update";
        if (metaID && !metaValue) {
            operation = @"delete";
        } else if (!metaID && metaValue) {
            operation = @"add";
        }
        NSMutableDictionary *modifiedMeta = [meta mutableCopy];
        modifiedMeta[@"operation"] = operation;
        return [NSDictionary dictionaryWithDictionary:modifiedMeta];
    }];
}

- (NSArray *)remoteCategoriesFromJSONArray:(NSArray *)jsonCategories {
    return [jsonCategories wp_map:^id(NSDictionary *jsonCategory) {
        return [self remoteCategoryFromJSONDictionary:jsonCategory];
    }];
}

- (RemotePostCategory *)remoteCategoryFromJSONDictionary:(NSDictionary *)jsonCategory {
    RemotePostCategory *category = [RemotePostCategory new];
    category.categoryID = jsonCategory[@"ID"];
    category.name = jsonCategory[@"name"];
    category.parentID = jsonCategory[@"parent"];

    return category;
}

- (NSArray *)tagNamesFromJSONDictionary:(NSDictionary *)jsonTags {
    return [jsonTags allKeys];
}

@end
