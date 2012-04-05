
require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'
require 'opencv-ffi-ext/misc.rb'

module CVFFI

  module Features2D

    class CvKeyPoint < NiceFFI::Struct
      layout :x, :float,
        :y, :float,
        :kp_size, :float,
        :angle, :float,
        :response, :float,
        :octave, :int
    end

    class CvEllipticKeyPoint < NiceFFI::Struct
      layout :centre, CvPoint,
        :axes, CvSize2D32f,
        :phi, :double,
        :kp_size, :float,
        :si, :float,
        :transf, CvMat
    end

    class Keypoints
      include Enumerable
      include MapWithIndex

      attr_reader :kps
      attr_reader :desc

      def initialize( k, mem_storage = nil, descriptors = nil)
        if k.is_a? CvSeq
          @kps = Sequence.new( k )
          @results = Array.new( @kps.size )
          @mem_storage = mem_storage

          destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @mem_storage ); cvReleaseMemStorage( poolPtr ) }
          ObjectSpace.define_finalizer( self, destructor )
        else
          @kps = nil
          @results = k
        end

        @desc = descriptors if descriptors
      end

      def size
        @results.size
      end
      alias :length :size

      def each
        size.times { |i|
          yield at(i)
        }
      end

      def [](i)
        raise "Request for result out of bounds" if (i < 0 or i >= size)
        unless @results[i]
          @results[i] = CvKeyPoint.new( @kps[i] )
          if @desc
            @results[i].descriptor =  @desc[i]
          end
        end
        @results[i]
      end
      alias :at :[]

      def to_a
        map_with_index { |kp,i|
          a = [ kp.x, kp.y, kp.kp_size, kp.angle, kp.response, kp.octave ]
          a << @desc[i].to_a if @desc
          a
        }
      end

      def to_yaml
        to_a.to_yaml
      end

      def self.from_a( a )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array

        descriptors = []
        kps = a.map { |a|
          kp = CvKeyPoint.new( a[0,6] )
          if a[7]
            ## Extract descriptors as well
            kp.descriptors << a[7]
          end
          kp
        }

        if descriptors.length > 0
          Keypoints.new( kps, nil, descriptors )
        else
          Keypoints.new( kps )
        end
      end
    end

    # TODO:  Combine with above
    class EllipticKeypoints
      include Enumerable

      attr_reader :kps
      attr_reader :desc

      def initialize( k, mem_storage = nil, descriptors = nil)
        if k.is_a? CvSeq
          @kps = Sequence.new( k )
          @results = Array.new( @kps.size )
          @mem_storage = mem_storage

          destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @mem_storage ); cvReleaseMemStorage( poolPtr ) }
          ObjectSpace.define_finalizer( self, destructor )
        else
          @kps = nil
          @results = k
        end

        @desc = descriptors if descriptors
      end

      def size
        @results.size
      end
      alias :length :size

      def each
        size.times { |i|
          yield at(i)
        }
      end

      def [](i)
        raise "Request for result out of bounds" if (i < 0 or i >= size)
        unless @results[i]
          @results[i] = CvEllipticKeyPoint.new( @kps[i] )
          if @desc
            @results[i].descriptor =  @desc[i]
          end
        end
        @results[i]
      end
      alias :at :[]

      def to_a
        ary = []
        # Would work better with map_with_index
        each_with_index { |kp,i|
          a = [ kp.x, kp.y, kp.kp_size, kp.angle, kp.response, kp.octave ]
          a << @desc[i].to_a if @desc
          ary << a
        }
        ary
      end

      def self.from_a( a )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array

        descriptors = []
        kps = a.map { |a|
          kp = CvEllipticKeyPoint.new( a[0,6] )
          if a[7]
            ## Extract descriptors as well
            kp.descriptors << a[7]
          end
          kp
        }

        if descriptors.length > 0
          EllipticKeypoints.new( kps, nil, descriptors )
        else
          EllipticKeypoints.new( kps )
        end
      end
    end


  end
end
