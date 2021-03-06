#import "AccountServiceRemoteREST.h"
#import "WordPressComApi.h"
#import "RemoteBlog.h"
#import "Constants.h"
#import "WPAccount.h"
#import "JetpackREST.h"

static NSString * const UserDictionaryIDKey = @"ID";
static NSString * const UserDictionaryUsernameKey = @"username";
static NSString * const UserDictionaryEmailKey = @"email";
static NSString * const UserDictionaryDisplaynameKey = @"display_name";
static NSString * const UserDictionaryPrimaryBlogKey = @"primary_blog";
static NSString * const UserDictionaryAvatarURLKey = @"avatar_URL";

@implementation AccountServiceRemoteREST

- (void)getBlogsWithSuccess:(void (^)(NSArray *))success
                    failure:(void (^)(NSError *))failure
{
    NSString *requestUrl = [self pathForEndpoint:@"me/sites"
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    [self.api GET:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  success([self remoteBlogsFromJSONArray:responseObject[@"sites"]]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)getDetailsForAccount:(WPAccount *)account
                     success:(void (^)(RemoteUser *remoteUser))success
                     failure:(void (^)(NSError *error))failure
{
    // IMPORTANT: We're adding this assertion even though the account is not used here to let the
    // caller know this parameter needs to be set (following the documentation of the protocol).
    // This parameter is used and required by the XMLRPC variant of this method.
    //
    NSParameterAssert([account isKindOfClass:[WPAccount class]]);
    
    NSString *requestUrl = [self pathForEndpoint:@"me"
                                     withVersion:ServiceRemoteRESTApiVersion_1_1];
    
    [self.api GET:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
              if (!success) {
                  return;
              }
              RemoteUser *remoteUser = [self remoteUserFromDictionary:responseObject];
              success(remoteUser);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}



#pragma mark - Private Methods

- (RemoteUser *)remoteUserFromDictionary:(NSDictionary *)dictionary
{
    RemoteUser *remoteUser = [RemoteUser new];
    remoteUser.userID = [dictionary numberForKey:UserDictionaryIDKey];
    remoteUser.username = [dictionary stringForKey:UserDictionaryUsernameKey];
    remoteUser.email = [dictionary stringForKey:UserDictionaryEmailKey];
    remoteUser.displayName = [dictionary stringForKey:UserDictionaryDisplaynameKey];
    remoteUser.primaryBlogID = [dictionary numberForKey:UserDictionaryPrimaryBlogKey];
    remoteUser.avatarURL = [dictionary stringForKey:UserDictionaryAvatarURLKey];
    return remoteUser;
}

- (NSArray *)remoteBlogsFromJSONArray:(NSArray *)jsonBlogs
{
    NSArray *blogs = jsonBlogs;
    if (!JetpackREST.enabled) {
        blogs = [blogs wp_filter:^BOOL(NSDictionary *jsonBlog) {
            BOOL isJetpack = [jsonBlog[@"jetpack"] boolValue];
            return !isJetpack;
        }];
    }
    return [blogs wp_map:^id(NSDictionary *jsonBlog) {
        return [self remoteBlogFromJSONDictionary:jsonBlog];
    }];
}

- (RemoteBlog *)remoteBlogFromJSONDictionary:(NSDictionary *)jsonBlog
{
    RemoteBlog *blog = [RemoteBlog new];
    blog.ID =  [jsonBlog numberForKey:@"ID"];
    blog.title = [jsonBlog stringForKey:@"name"];
    blog.desc = [jsonBlog stringForKey:@"description"];
    blog.url = [jsonBlog stringForKey:@"URL"];
    blog.xmlrpc = [jsonBlog stringForKeyPath:@"meta.links.xmlrpc"];
    blog.jetpack = [[jsonBlog numberForKey:@"jetpack"] boolValue];
    blog.icon = [jsonBlog stringForKeyPath:@"icon.img"];
    blog.isAdmin = [[jsonBlog numberForKeyPath:@"capabilities.manage_options"] boolValue];
    return blog;
}

@end
