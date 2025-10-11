# frozen_string_literal: true

# Workaround for OpenSSL 3.6.0 regression bug
# OpenSSL 3.6.0 (released Oct 2025) has a bug where V_FLAG_CRL_CHECK_ALL
# is set by default, causing "certificate verify failed (unable to get certificate CRL)" errors
# See: https://github.com/openssl/openssl/issues/28758
#      https://github.com/ruby/openssl/issues/949
#
require 'openssl'

store = OpenSSL::X509::Store.new
store.set_default_paths
# Set flags to 0 to clear the problematic CRL check flags
store.flags = 0

OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_CERT_STORE) if OpenSSL::SSL::SSLContext.const_defined?(:DEFAULT_CERT_STORE)
OpenSSL::SSL::SSLContext.const_set(:DEFAULT_CERT_STORE, store.freeze)
