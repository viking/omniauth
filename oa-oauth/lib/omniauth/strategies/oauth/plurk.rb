require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Plurk via OAuth and retrieve basic user info.
    #
    # Please note that this strategy relies on Plurk API 2.0,
    # which is still in Beta.
    #
    # Usage:
    #   use OmniAuth::Strategies::Plurk
    class Plurk < OmniAuth::Strategies::OAuth

      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_key App key [registered on plurk] (http://www.plurk.com/PlurkApp/register)
      # @param [String] consumer_secret App secret registered on plurk
      def initialize(app, consumer_key=nil, consumer_secret=nil, options = {}, &block)
        client_options = {
          :authorize_url => 'http://www.plurk.com/OAuth/authorize',
          :token_url => 'http://www.plurk.com/OAuth/access_token',
        }
        super(app, :plurk, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        user = self.user_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user = self.user_hash
        {
          'name' => user['full_name'],
          'nickname' => user['display_name'] || user['nick_name'],
          'location' => user['location'],
          'image' => if user['has_profile_image'] == 1
                        "http://avatars.plurk.com/#{user['id']}-medium#{user['avatar']}.gif"
                      else
                        "http://www.plurk.com/static/default_medium.gif"
                      end,
          'urls' => { 'Plurk' => 'http://plurk.com/' + user['nick_name']}
        }
      end

      def user_hash
        @user_hash  ||= MultiJson.decode(@access_token.get('/APP/Profile/getOwnProfile').body)['user_info']
      end

    end
  end
end
