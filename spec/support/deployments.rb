module Bosh::Spec
  class Deployments
    # This is a minimal manifest that deploys successfully.
    # It doesn't have any jobs, so it's not very realistic though
    def self.minimal_cloud_config
      {
        'networks' => [{
            'name' => 'a',
            'subnets' => [],
          }],

        'compilation' => {
          'workers' => 1,
          'network' => 'a',
          'cloud_properties' => {},
        },

        'resource_pools' => [],
      }
    end

    def self.simple_cloud_config
      minimal_cloud_config.merge({
          'networks' => [network],

          'resource_pools' => [resource_pool]
        })
    end

    def self.network(options = {})
      {
        'name' => 'a',
        'subnets' => [subnet],
      }.merge!(options)
    end

    def self.subnet(options = {})
      {
        'range' => '192.168.1.0/24',
        'gateway' => '192.168.1.1',
        'dns' => ['192.168.1.1', '192.168.1.2'],
        'static' => ['192.168.1.10'],
        'reserved' => [],
        'cloud_properties' => {},
      }.merge!(options)
    end

    def self.resource_pool
      {
        'name' => 'a',
        'size' => 3,
        'cloud_properties' => {},
        'network' => 'a',
        'stemcell' => {
          'name' => 'ubuntu-stemcell',
          'version' => '1',
        },
      }
    end

    def self.disk_pool
      {
        'name' => 'disk_a',
        'disk_size' => 123
      }
    end

    def self.minimal_manifest
      {
        'name' => 'minimal',
        'director_uuid'  => 'deadbeef',

        'releases' => [{
          'name'    => 'appcloud',
          'version' => '0.1' # It's our dummy valid release from spec/assets/valid_release.tgz
        }],

        'update' => {
          'canaries'          => 2,
          'canary_watch_time' => 4000,
          'max_in_flight'     => 1,
          'update_watch_time' => 20
        }
      }
    end

    def self.minimal_legacy_manifest
      simple_cloud_config.merge(
      {
          'name' => 'minimal_legacy_manifest',
          'director_uuid'  => 'deadbeef',

          'releases' => [{
               'name'    => 'appcloud',
               'version' => '0.1' # It's our dummy valid release from spec/assets/valid_release.tgz
           }],

          'update' => {
              'canaries'          => 2,
              'canary_watch_time' => 4000,
              'max_in_flight'     => 1,
              'update_watch_time' => 20
          }
      })
    end

    def self.multiple_release_manifest
      {
          'name' => 'minimal',
          'director_uuid'  => 'deadbeef',

          'releases' => [{
               'name'    => 'appcloud',
               'version' => '0.1' # It's our dummy valid release from spec/assets/valid_release.tgz
           },{
               'name'    => 'appcloud_2',
               'version' => '0.2' # It's our dummy valid release from spec/assets/valid_release_2.tgz
           }],

          'update' => {
              'canaries'          => 2,
              'canary_watch_time' => 4000,
              'max_in_flight'     => 1,
              'update_watch_time' => 20
          }
      }
    end

    def self.legacy_manifest
      simple_cloud_config.merge(simple_manifest)
    end

    def self.test_release_manifest
      minimal_manifest.merge(
        'name' => 'simple',

        'releases' => [{
          'name'    => 'bosh-release',
          'version' => '0.1-dev',
        }]
      )
    end

    def self.simple_manifest
      test_release_manifest.merge({
        'jobs' => [simple_job]
      })
    end

    def self.simple_job(opts = {})
      job_hash = {
        'name' => opts.fetch(:name, 'foobar'),
        'templates' => opts.fetch(:templates, ['name' => 'foobar']),
        'resource_pool' => 'a',
        'instances' => opts.fetch(:instances, 3),
        'networks' => [{
            'name' => 'a',
          }],
        'properties' => {},
      }

      if opts.has_key?(:static_ips)
        job_hash['networks'].first['static_ips'] = opts[:static_ips]
      end

      job_hash
    end

    def self.manifest_with_errand
      manifest = simple_manifest.merge('name' => 'errand')
      manifest['jobs'].find { |job| job['name'] == 'foobar'}['instances'] = 1
      manifest['jobs'] << simple_errand_job
      manifest
    end

    def self.simple_errand_job
      {
        'name' => 'fake-errand-name',
        'template' => 'errand1',
        'lifecycle' => 'errand',
        'resource_pool' => 'a',
        'instances' => 1,
        'networks' => [{'name' => 'a'}],
        'properties' => {
          'errand1' => {
            'exit_code' => 0,
            'stdout' => 'fake-errand-stdout',
            'stderr' => 'fake-errand-stderr',
            'run_package_file' => true,
          },
        },
      }
    end
  end
end
