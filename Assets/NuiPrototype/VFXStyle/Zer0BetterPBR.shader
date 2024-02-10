// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "!Zer0/BetterPBRWater"
{
	Properties
	{
		[SingleLineTexture]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_Color("MainColor", Color) = (1,1,1,0)
		_SpeedMainTex1("SpeedMainTex", Vector) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_BumpMap("BumpMap", 2D) = "bump" {}
		_NormalStrength1("NormalStrength", Range( 0 , 1)) = 0
		[NoScaleOffset][SingleLineTexture]_RoughnessMap("RoughnessMap", 2D) = "white" {}
		_GlossMapScaless("Smoothness", Range( 0 , 50)) = 0.5
		[NoScaleOffset][SingleLineTexture]_OcclusionMap("OcclusionMap", 2D) = "white" {}
		_OcclusionStrength("OcclusionStrength", Range( 0 , 1)) = 1
		[NoScaleOffset][SingleLineTexture]_SparkleMap("SparkleMap", 2D) = "white" {}
		_SparkleStrength1("SparkleStrength", Float) = 0
		[SingleLineTexture]_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_EmissionStrength1("EmissionStrength", Float) = 0
		_SpeedEmission1("SpeedEmission", Vector) = (0,0,0,0)
		[SingleLineTexture]_Leafes("Leafes", 2D) = "white" {}
		_LeafScroll1("LeafScroll", Vector) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_LeafNormal("LeafNormal", 2D) = "bump" {}
		_LeafNormalStrength1("LeafNormalStrength", Range( 0 , 1)) = 0
		_SmoothStepLeafMask1("SmoothStepLeafMask", Vector) = (0,1,0,0)
		_LeafMaskUV1("LeafMaskUV", Vector) = (1,1,-0.5,-0.5)
		[SingleLineTexture]_Distortion("Distortion", 2D) = "bump" {}
		_DistortionStrength1("Distortion Strength", Float) = 0
		_DistortionScroll1("DistortionScroll", Vector) = (0,0,0,0)
		_Waves("Waves", 2D) = "white" {}
		_TilingWaves1("Tiling Waves", Vector) = (0,0,0,0)
		_SpeedWaves1("SpeedWaves", Vector) = (0,0,0,0)
		_OffsetStrength1("OffsetStrength", Float) = 0
		_LightmapStrength("LightmapStrength", Range( 0 , 3)) = 1
		_RealtimeStrength("RealtimeStrength", Range( 0 , 3)) = 1
		[Toggle]_UseWorldReflection("UseWorldReflection", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Waves;
		uniform float2 _SpeedWaves1;
		uniform float2 _TilingWaves1;
		uniform float _OffsetStrength1;
		uniform sampler2D _EmissionMap;
		uniform float2 _SpeedEmission1;
		uniform float4 _EmissionMap_ST;
		uniform float _EmissionStrength1;
		uniform sampler2D _SparkleMap;
		uniform sampler2D _Distortion;
		uniform float2 _DistortionScroll1;
		uniform float4 _Distortion_ST;
		uniform float _DistortionStrength1;
		uniform float2 _SpeedMainTex1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _SparkleStrength1;
		uniform sampler2D _Leafes;
		uniform float2 _LeafScroll1;
		uniform float4 _Leafes_ST;
		uniform float2 _SmoothStepLeafMask1;
		uniform float4 _LeafMaskUV1;
		uniform float4 _EmissionColor;
		uniform float _UseWorldReflection;
		uniform sampler2D _BumpMap;
		uniform float _NormalStrength1;
		uniform sampler2D _LeafNormal;
		uniform float _LeafNormalStrength1;
		uniform sampler2D _RoughnessMap;
		uniform float _GlossMapScaless;
		uniform float _LightmapStrength;
		uniform float _RealtimeStrength;
		uniform float _Metallic;
		uniform float4 _Color;
		uniform sampler2D _OcclusionMap;
		uniform float _OcclusionStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult171 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float2 panner186 = ( 1.0 * _Time.y * _SpeedWaves1 + ( appendResult171 * float4( _TilingWaves1, 0.0 , 0.0 ) ).xy);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( tex2Dlod( _Waves, float4( panner186, 0, 0.0) ) * _OffsetStrength1 * float4( ase_vertexNormal , 0.0 ) ).rgb;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner153 = ( 1.0 * _Time.y * _DistortionScroll1 + uv_Distortion);
			float3 temp_output_162_0 = ( UnpackNormal( tex2D( _Distortion, panner153 ) ) * _DistortionStrength1 );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner158 = ( 1.0 * _Time.y * _SpeedMainTex1 + uv_MainTex);
			float3 temp_output_187_0 = ( temp_output_162_0 + float3( panner158 ,  0.0 ) );
			float2 uv_Leafes = i.uv_texcoord * _Leafes_ST.xy + _Leafes_ST.zw;
			float2 panner174 = ( 1.0 * _Time.y * _LeafScroll1 + uv_Leafes);
			float3 temp_output_206_0 = ( UnpackScaleNormal( tex2D( _BumpMap, temp_output_187_0.xy ), _NormalStrength1 ) + UnpackScaleNormal( tex2D( _LeafNormal, panner174 ), _LeafNormalStrength1 ) );
			float3 indirectNormal74 = normalize( WorldNormalVector( i , temp_output_206_0 ) );
			float4 temp_output_87_0 = ( tex2D( _RoughnessMap, temp_output_187_0.xy ) * _GlossMapScaless );
			Unity_GlossyEnvironmentData g74 = UnityGlossyEnvironmentSetup( temp_output_87_0.r, data.worldViewDir, indirectNormal74, float3(0,0,0));
			float3 indirectSpecular74 = UnityGI_IndirectSpecular( data, _GlossMapScaless, indirectNormal74, g74 );
			float3 indirectNormal81 = temp_output_206_0;
			Unity_GlossyEnvironmentData g81 = UnityGlossyEnvironmentSetup( temp_output_87_0.r, data.worldViewDir, indirectNormal81, float3(0,0,0));
			float3 indirectSpecular81 = UnityGI_IndirectSpecular( data, _GlossMapScaless, indirectNormal81, g81 );
			float3 temp_output_107_0 = saturate( (( _UseWorldReflection )?( indirectSpecular81 ):( indirectSpecular74 )) );
			UnityGI gi38 = gi;
			float3 diffNorm38 = temp_output_206_0;
			gi38 = UnityGI_Base( data, 1, diffNorm38 );
			float3 indirectDiffuse38 = gi38.indirect.diffuse + diffNorm38 * 0.0001;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 normalizeResult44 = normalize( (WorldNormalVector( i , temp_output_206_0 )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult40 = dot( normalizeResult44 , ase_worldlightDir );
			float3 lerpResult118 = lerp( ( temp_output_107_0 + ( saturate( ( indirectDiffuse38 * _LightmapStrength ) ) + saturate( ( ( ase_lightColor.rgb * ase_lightAtten ) * max( dotResult40 , 0.0 ) * _RealtimeStrength ) ) ) ) , temp_output_107_0 , _Metallic);
			float4 tex2DNode181 = tex2D( _Leafes, panner174 );
			float2 appendResult161 = (float2(_LeafMaskUV1.x , _LeafMaskUV1.y));
			float2 appendResult159 = (float2(_LeafMaskUV1.z , _LeafMaskUV1.w));
			float2 uv_TexCoord169 = i.uv_texcoord * appendResult161 + appendResult159;
			float smoothstepResult180 = smoothstep( _SmoothStepLeafMask1.x , _SmoothStepLeafMask1.y , length( uv_TexCoord169 ));
			float temp_output_197_0 = saturate( ( tex2DNode181.a - smoothstepResult180 ) );
			float4 lerpResult202 = lerp( tex2D( _MainTex, temp_output_187_0.xy ) , tex2DNode181 , temp_output_197_0);
			float4 temp_output_54_0 = ( float4( lerpResult118 , 0.0 ) * lerpResult202 * _Color );
			float4 lerpResult126 = lerp( temp_output_54_0 , ( tex2D( _OcclusionMap, temp_output_187_0.xy ) * temp_output_54_0 ) , _OcclusionStrength);
			c.rgb = saturate( lerpResult126 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float2 panner167 = ( 1.0 * _Time.y * _SpeedEmission1 + uv_EmissionMap);
			float2 uv_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner153 = ( 1.0 * _Time.y * _DistortionScroll1 + uv_Distortion);
			float3 temp_output_162_0 = ( UnpackNormal( tex2D( _Distortion, panner153 ) ) * _DistortionStrength1 );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner158 = ( 1.0 * _Time.y * _SpeedMainTex1 + uv_MainTex);
			float2 uv_Leafes = i.uv_texcoord * _Leafes_ST.xy + _Leafes_ST.zw;
			float2 panner174 = ( 1.0 * _Time.y * _LeafScroll1 + uv_Leafes);
			float4 tex2DNode181 = tex2D( _Leafes, panner174 );
			float2 appendResult161 = (float2(_LeafMaskUV1.x , _LeafMaskUV1.y));
			float2 appendResult159 = (float2(_LeafMaskUV1.z , _LeafMaskUV1.w));
			float2 uv_TexCoord169 = i.uv_texcoord * appendResult161 + appendResult159;
			float smoothstepResult180 = smoothstep( _SmoothStepLeafMask1.x , _SmoothStepLeafMask1.y , length( uv_TexCoord169 ));
			float temp_output_197_0 = saturate( ( tex2DNode181.a - smoothstepResult180 ) );
			float4 lerpResult205 = lerp( saturate( ( ( tex2D( _EmissionMap, panner167 ) * _EmissionStrength1 ) + ( tex2D( _SparkleMap, ( temp_output_162_0 + float3( ( panner158 * 0.8 ) ,  0.0 ) ).xy ) * _SparkleStrength1 ) ) ) , float4( 0,0,0,0 ) , temp_output_197_0);
			o.Emission = ( lerpResult205 * _EmissionColor ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.Vector2Node;150;-5837.275,-530.0587;Inherit;False;Property;_DistortionScroll1;DistortionScroll;24;0;Create;True;0;0;0;False;0;False;0,0;0,2.96;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-5940.275,-701.0587;Inherit;False;0;156;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;153;-5548.275,-556.0587;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-5023.35,-290.7151;Inherit;False;Property;_DistortionStrength1;Distortion Strength;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-5586.037,-356.0388;Inherit;False;0;196;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;151;-5482.037,-185.0388;Inherit;False;Property;_SpeedMainTex1;SpeedMainTex;2;0;Create;True;0;0;0;False;0;False;0,0;0,0.42;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;156;-5135.716,-477.7672;Inherit;True;Property;_Distortion;Distortion;22;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-4772.35,-342.7151;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;165;-4746.975,-707.8126;Inherit;False;0;181;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;158;-5193.037,-211.0388;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;170;-4711.315,-584.109;Inherit;False;Property;_LeafScroll1;LeafScroll;16;0;Create;True;0;0;0;False;0;False;0,0;0,1.69;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;187;-4562.037,-248.0388;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-4640.899,15.21093;Inherit;False;Property;_NormalStrength1;NormalStrength;4;0;Create;True;0;0;0;False;0;False;0;0.579;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;174;-4422.316,-610.109;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-4505.166,-384.6227;Inherit;False;Property;_LeafNormalStrength1;LeafNormalStrength;18;0;Create;True;0;0;0;False;0;False;0;0.588;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;200;-4349.702,-47.46061;Inherit;True;Property;_BumpMap;BumpMap;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;193;-4228.854,-441.6085;Inherit;True;Property;_LeafNormal;LeafNormal;17;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;91;-2246.091,626.3533;Inherit;False;1059.731;454.3219;;11;108;35;72;39;68;40;62;59;47;44;45;RealtimeLight;0.9830742,1,0.4481132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-1713.056,-111.8287;Inherit;False;812.3177;247.336;;5;69;38;70;71;64;Baked Light;0.7957219,1,0.5424528,1;0;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;38;-1663.056,-52.42598;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1638.024,20.50719;Inherit;False;Property;_LightmapStrength;LightmapStrength;29;0;Create;True;0;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1383.224,-44.49272;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;154;-4318.926,-899.1453;Inherit;False;Property;_LeafMaskUV1;LeafMaskUV;20;0;Create;True;0;0;0;False;0;False;1,1,-0.5,-0.5;99,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;71;-1245.423,-40.29275;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;93;-2516.122,-906.5613;Inherit;False;1843.901;667.0502;;9;118;119;107;87;80;74;81;77;120;Reflection aka Metallic;0.509434,0.509434,0.509434,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2442.721,-672.6111;Inherit;False;Property;_GlossMapScaless;Smoothness;6;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;161;-4110.591,-872.8406;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1010.722,-35.88956;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;198;-4397.598,684.2719;Inherit;True;Property;_RoughnessMap;RoughnessMap;5;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;159;-4124.27,-767.6214;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;169;-3960.129,-832.8572;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.5,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2142.321,-762.3615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;148;-885.4191,-56.14536;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;81;-1730.12,-703.3116;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;74;-1740.521,-838.5114;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-4812.037,393.9613;Inherit;False;Constant;_Float3;Float 2;15;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;177;-3685.506,-570.8612;Inherit;False;Property;_SmoothStepLeafMask1;SmoothStepLeafMask;19;0;Create;True;0;0;0;False;0;False;0,1;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LengthOpNode;175;-3724.438,-800.2393;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;147;-881.0195,-91.3454;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;180;-3451.92,-796.0305;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.23;False;2;FLOAT;0.37;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;164;-5165.037,120.628;Inherit;False;Property;_SpeedEmission1;SpeedEmission;14;0;Create;True;0;0;0;False;0;False;0,0;0,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-5268.037,-49.37199;Inherit;False;0;179;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;146;-821.6193,-137.5454;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;80;-1461.019,-778.7114;Inherit;False;Property;_UseWorldReflection;UseWorldReflection;31;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-4656.037,335.9613;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;181;-4236.438,-635.9295;Inherit;True;Property;_Leafes;Leafes;15;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-4507.037,285.9613;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;107;-1199.26,-772.8654;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;188;-3495.06,-439.3371;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;167;-4876.037,94.62805;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;136;-817.9227,-175.9173;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;168;-307.0994,1044.087;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;145;-831.7542,-9.904223;Inherit;False;673.4282;453.0632;;2;54;113;MainTex;1,0.514151,0.514151,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1465.933,-631.2326;Inherit;False;Property;_Metallic;Metallic;32;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-4277.038,583.9612;Inherit;False;Property;_SparkleStrength1;SparkleStrength;10;0;Create;True;0;0;0;False;0;False;0;4.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-4304.038,327.9613;Inherit;False;Property;_EmissionStrength1;EmissionStrength;13;0;Create;True;0;0;0;False;0;False;0;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;179;-4389.702,152.5394;Inherit;True;Property;_EmissionMap;EmissionMap;11;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;197;-3186.767,-413.0322;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;196;-4410.702,-249.4608;Inherit;True;Property;_MainTex;MainTex;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;178;-4391.038,402.9613;Inherit;True;Property;_SparkleMap;SparkleMap;9;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-998.9442,-827.2334;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-4052.038,459.9613;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;173;263.8999,1211.087;Inherit;False;Property;_TilingWaves1;Tiling Waves;26;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;171;113.8998,1130.087;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-4044.038,224.9613;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;202;-3750.202,-284.7256;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;113;-696.6688,236.159;Inherit;False;Property;_Color;MainColor;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;118;-828.243,-774.433;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;183;-198.0994,884.0868;Inherit;False;Property;_SpeedWaves1;SpeedWaves;27;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-327.3261,73.4012;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;204;-4394.702,966.5392;Inherit;True;Property;_OcclusionMap;OcclusionMap;7;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-3821.475,262.4915;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;129;-107.2754,-320.1239;Inherit;False;730.4437;504.2393;;4;102;126;127;106;Occlusion;0.4466978,1,0.4103774,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;497.0214,1097.087;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;128;-61.55862,-892.9554;Inherit;False;562.8282;463.1635;;2;116;115;Emission;1,0.5424528,0.9809616,1;0;0
Node;AmplifyShaderEditor.PannerNode;186;12.90033,738.087;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;199;-3659.202,337.1812;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2670.123,144.1573;Inherit;False;609.2798;280;;1;63;Normals;0.2216981,0.7799206,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;194;646.0215,913.087;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;201;347.8999,605.0868;Inherit;True;Property;_Waves;Waves;25;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;195;649.0215,832.0872;Inherit;False;Property;_OffsetStrength1;OffsetStrength;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;-92.83662,245.3149;Inherit;False;390.2;248.1999;;2;125;124;Cutout;1,0.7869138,0.504717,1;0;0
Node;AmplifyShaderEditor.ColorNode;116;76.12665,-636.7921;Inherit;False;Property;_EmissionColor;EmissionColor;12;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;125;-42.83664,378.5148;Inherit;False;Property;_Cutoff;Alpha Cutoff;33;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2629.123,287.508;Inherit;False;Property;_BumpScale;NormalStrength;21;0;Create;False;0;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;332.2694,-661.2503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;838.0214,650.0869;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;128.3635,295.3149;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;44;-1937.216,865.2334;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;68;-1627.66,865.6255;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;-1354.59,780.1472;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1713.912,772.5861;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1716.344,685.3273;Inherit;False;Property;_RealtimeStrength;RealtimeStrength;30;0;Create;True;0;0;0;False;0;False;1;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;45;-2196.091,863.737;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;205;-3273.038,266.067;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;206;-3538.893,2.266006;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1559.41,-211.5668;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;!Zer0/BetterPBRWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;1;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0;True;False;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;111.884,-147.2375;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-54.71117,69.11552;Inherit;False;Property;_OcclusionStrength;OcclusionStrength;8;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;126;263.6889,-26.88449;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;106;384.4554,-32.84005;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;59;-1949.955,792.6678;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;62;-1896.916,666.3532;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;47;-1988.188,937.061;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1495.131,792.4405;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;40;-1754.995,866.5063;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
WireConnection;153;0;149;0
WireConnection;153;2;150;0
WireConnection;156;1;153;0
WireConnection;162;0;156;0
WireConnection;162;1;155;0
WireConnection;158;0;152;0
WireConnection;158;2;151;0
WireConnection;187;0;162;0
WireConnection;187;1;158;0
WireConnection;174;0;165;0
WireConnection;174;2;170;0
WireConnection;200;1;187;0
WireConnection;200;5;191;0
WireConnection;193;1;174;0
WireConnection;193;5;190;0
WireConnection;38;0;206;0
WireConnection;70;0;38;0
WireConnection;70;1;69;0
WireConnection;71;0;70;0
WireConnection;161;0;154;1
WireConnection;161;1;154;2
WireConnection;64;0;71;0
WireConnection;64;1;108;0
WireConnection;198;1;187;0
WireConnection;159;0;154;3
WireConnection;159;1;154;4
WireConnection;169;0;161;0
WireConnection;169;1;159;0
WireConnection;87;0;198;0
WireConnection;87;1;77;0
WireConnection;148;0;64;0
WireConnection;81;0;206;0
WireConnection;81;1;87;0
WireConnection;81;2;77;0
WireConnection;74;0;206;0
WireConnection;74;1;87;0
WireConnection;74;2;77;0
WireConnection;175;0;169;0
WireConnection;147;0;148;0
WireConnection;180;0;175;0
WireConnection;180;1;177;1
WireConnection;180;2;177;2
WireConnection;146;0;147;0
WireConnection;80;0;74;0
WireConnection;80;1;81;0
WireConnection;163;0;158;0
WireConnection;163;1;157;0
WireConnection;181;1;174;0
WireConnection;166;0;162;0
WireConnection;166;1;163;0
WireConnection;107;0;80;0
WireConnection;188;0;181;4
WireConnection;188;1;180;0
WireConnection;167;0;160;0
WireConnection;167;2;164;0
WireConnection;136;0;146;0
WireConnection;179;1;167;0
WireConnection;197;0;188;0
WireConnection;196;1;187;0
WireConnection;178;1;166;0
WireConnection;119;0;107;0
WireConnection;119;1;136;0
WireConnection;185;0;178;0
WireConnection;185;1;172;0
WireConnection;171;0;168;1
WireConnection;171;1;168;3
WireConnection;182;0;179;0
WireConnection;182;1;176;0
WireConnection;202;0;196;0
WireConnection;202;1;181;0
WireConnection;202;2;197;0
WireConnection;118;0;119;0
WireConnection;118;1;107;0
WireConnection;118;2;120;0
WireConnection;54;0;118;0
WireConnection;54;1;202;0
WireConnection;54;2;113;0
WireConnection;204;1;187;0
WireConnection;189;0;182;0
WireConnection;189;1;185;0
WireConnection;184;0;171;0
WireConnection;184;1;173;0
WireConnection;186;0;184;0
WireConnection;186;2;183;0
WireConnection;199;0;189;0
WireConnection;201;1;186;0
WireConnection;115;0;205;0
WireConnection;115;1;116;0
WireConnection;207;0;201;0
WireConnection;207;1;195;0
WireConnection;207;2;194;0
WireConnection;124;0;197;0
WireConnection;124;1;125;0
WireConnection;44;0;45;0
WireConnection;68;0;40;0
WireConnection;108;0;35;0
WireConnection;39;0;62;1
WireConnection;39;1;59;0
WireConnection;45;0;206;0
WireConnection;205;0;199;0
WireConnection;205;2;197;0
WireConnection;206;0;200;0
WireConnection;206;1;193;0
WireConnection;0;2;115;0
WireConnection;0;13;106;0
WireConnection;0;11;207;0
WireConnection;102;0;204;0
WireConnection;102;1;54;0
WireConnection;126;0;54;0
WireConnection;126;1;102;0
WireConnection;126;2;127;0
WireConnection;106;0;126;0
WireConnection;35;0;39;0
WireConnection;35;1;68;0
WireConnection;35;2;72;0
WireConnection;40;0;44;0
WireConnection;40;1;47;0
ASEEND*/
//CHKSM=479A54A1AEBC3A447F51EF349D6708DBCAE4EEBC