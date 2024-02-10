// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Zer0/Customs V3 Toon"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_MainScrollingX("Main Scrolling X", Range( -20 , 20)) = 0
		_MainScrollingY("Main Scrolling Y", Range( -20 , 20)) = 0
		_MainStrength("Main Strength", Range( -10 , 10)) = 1
		_MainColor("Main Color", Color) = (1,1,1,0)
		_Overlay("Overlay", 2D) = "white" {}
		_OverlayScrollingX("Overlay Scrolling X", Range( -20 , 20)) = 0
		_OverlayScrollingY("Overlay Scrolling Y", Range( -20 , 20)) = 0
		_OverlayStrength("Overlay Strength", Range( -10 , 10)) = 1
		_OverlayColor("Overlay Color", Color) = (1,1,1,0)
		_BaseEmission("Base Emission", Range( 0 , 1)) = 0
		_Blend("Blend", Range( 0 , 1)) = 0
		[Toggle]_EnableCutoutOverlay("EnableCutoutOverlay", Float) = 0
		[Toggle]_EnableCutoutMain("EnableCutoutMain", Float) = 0
		_CutoutAmount("CutoutAmount", Float) = 1
		_EmissionTex("EmissionTex", 2D) = "white" {}
		_EmissionStrength("Emission Strength", Range( -10 , 10)) = 0
		_EmissionScrollingX("Emission Scrolling X", Range( -20 , 20)) = 0
		_EmissionScrollingY("Emission Scrolling Y", Range( -20 , 20)) = 0
		_EmissionColor0("EmissionColor0", Color) = (1,1,1,0)
		[Toggle]_EnableEmissionPulse("Enable Emission Pulse", Float) = 0
		_PulseSpeed("Pulse Speed", Range( 0 , 10)) = 2
		_PulseBaseBrightness("Pulse Base Brightness", Range( 1 , 2)) = 1.3
		[Toggle]_EnableEmissionRainbow("Enable Emission Rainbow", Float) = 0
		_RainbowSpeed("Rainbow Speed", Range( 0 , 10)) = 0.3
		_RainbowSaturation("Rainbow Saturation", Range( 0 , 2)) = 0.8
		_MaterializationTexture("Materialization Texture", 2D) = "white" {}
		_MaterializationScrollingX("Materialization Scrolling X", Range( -20 , 20)) = 0
		_MaterializationScollingY("Materialization Scolling Y", Range( -20 , 20)) = 0
		_MaterializationAmount("Materialization Amount", Range( 0 , 5)) = 5
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[Toggle]_EnableRimLight("Enable Rim Light", Float) = 0
		_RimLightTexture("RimLight Texture", 2D) = "white" {}
		_ScrollRimX("Scroll Rim X", Range( -20 , 20)) = 0
		_ScrollRimY("Scroll Rim Y", Range( -20 , 20)) = 0
		_RimLightStrength("Rim Light Strength", Range( -1 , 20)) = 0
		_RimLightColor("Rim Light Color", Color) = (0,0,0,0)
		_DistortTexture("Distort Texture", 2D) = "white" {}
		_DistortScrollingX("Distort Scrolling X", Range( -20 , 20)) = 0
		_DistortScrollingY("Distort Scrolling Y", Range( -20 , 20)) = 0
		[Toggle]_DistortMain("Distort Main", Float) = 0
		[Toggle]_DistortOverlay("Distort Overlay", Float) = 0
		[Toggle]_DistortMaterialization("Distort Materialization", Float) = 0
		[Toggle]_DistortRim("DistortRim", Float) = 0
		[Toggle]_DistortEmission("Distort Emission", Float) = 0
		_DistortionStrength("Distortion Strength", Range( 0 , 2)) = 0
		_FakeLightAmount("Fake Light Amount", Range( 0 , 1)) = 0
		_FakeLightStrength("Fake Light Strength", Range( -5 , 10)) = 1
		_FakeLightColor("Fake Light Color", Color) = (0.4705882,0.4705882,0.4705882,0)
		_Brightness("Brightness", Range( 0 , 1)) = 1
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalMapStrength("Normal Map Strength", Range( 0 , 5)) = 0
		_ToonRamp("Toon Ramp", 2D) = "black" {}
		_Offset("Offset", Float) = 0.5
		_Scale("Scale", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldPos;
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

		uniform float _EnableRimLight;
		uniform sampler2D _MainTex;
		uniform float _MainScrollingX;
		uniform float _MainScrollingY;
		uniform float4 _MainTex_ST;
		uniform float _DistortMain;
		uniform float _DistortionStrength;
		uniform sampler2D _DistortTexture;
		uniform float _DistortScrollingX;
		uniform float _DistortScrollingY;
		uniform float4 _DistortTexture_ST;
		uniform float4 _MainColor;
		uniform float _MainStrength;
		uniform sampler2D _Overlay;
		uniform float _DistortOverlay;
		uniform float _OverlayScrollingX;
		uniform float _OverlayScrollingY;
		uniform float4 _Overlay_ST;
		uniform float4 _OverlayColor;
		uniform float _OverlayStrength;
		uniform float _Blend;
		uniform float _FakeLightStrength;
		uniform float4 _FakeLightColor;
		uniform float _FakeLightAmount;
		uniform float _RimLightStrength;
		uniform float4 _RimLightColor;
		uniform sampler2D _RimLightTexture;
		uniform float _ScrollRimX;
		uniform float _ScrollRimY;
		uniform float4 _RimLightTexture_ST;
		uniform float _DistortRim;
		uniform float _BaseEmission;
		uniform float _EnableEmissionRainbow;
		uniform float _EnableEmissionPulse;
		uniform sampler2D _EmissionTex;
		uniform float _EmissionScrollingX;
		uniform float _EmissionScrollingY;
		uniform float4 _EmissionTex_ST;
		uniform float _DistortEmission;
		uniform float4 _EmissionColor0;
		uniform float _EmissionStrength;
		uniform float _PulseBaseBrightness;
		uniform float _PulseSpeed;
		uniform float _RainbowSpeed;
		uniform float _RainbowSaturation;
		uniform sampler2D _MaterializationTexture;
		uniform float _MaterializationScrollingX;
		uniform float _MaterializationScollingY;
		uniform float4 _MaterializationTexture_ST;
		uniform float _DistortMaterialization;
		uniform float _MaterializationAmount;
		uniform float _EnableCutoutMain;
		uniform float _CutoutAmount;
		uniform float _EnableCutoutOverlay;
		uniform sampler2D _ToonRamp;
		uniform float _NormalMapStrength;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _Scale;
		uniform float _Offset;
		uniform float _Brightness;
		uniform float _Cutoff = 0.5;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 MyCustomExpression323( float3 In0 )
		{
			return ShadeSH9(float4(0,0,0,1));
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
			float mulTime181 = _Time.y * 0.1;
			float4 appendResult179 = (float4(_MaterializationScrollingX , _MaterializationScollingY , 0.0 , 0.0));
			float2 uv_MaterializationTexture = i.uv_texcoord * _MaterializationTexture_ST.xy + _MaterializationTexture_ST.zw;
			float2 panner180 = ( mulTime181 * appendResult179.xy + uv_MaterializationTexture);
			float2 break215 = panner180;
			float3 temp_cast_21 = (0.0).xxx;
			float mulTime65 = _Time.y * 0.1;
			float4 appendResult66 = (float4(_DistortScrollingX , _DistortScrollingY , 0.0 , 0.0));
			float2 uv_DistortTexture = i.uv_texcoord * _DistortTexture_ST.xy + _DistortTexture_ST.zw;
			float2 panner67 = ( mulTime65 * appendResult66.xy + uv_DistortTexture);
			float3 tex2DNode69 = UnpackScaleNormal( tex2D( _DistortTexture, panner67 ), _DistortionStrength );
			float3 break237 = lerp(temp_cast_21,tex2DNode69,_DistortMaterialization);
			float4 appendResult214 = (float4(( break215.x + break237.x ) , ( break237.y + break215.y ) , 0.0 , 0.0));
			float grayscale93 = Luminance(tex2D( _MaterializationTexture, appendResult214.xy ).rgb);
			float mulTime6 = _Time.y * 0.1;
			float4 appendResult27 = (float4(_MainScrollingX , _MainScrollingY , 0.0 , 0.0));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner7 = ( mulTime6 * appendResult27.xy + uv_MainTex);
			float2 break74 = panner7;
			float3 temp_cast_26 = (0.0).xxx;
			float3 break234 = lerp(temp_cast_26,tex2DNode69,_DistortMain);
			float4 appendResult76 = (float4(( break74.x + break234.x ) , ( break74.y + break234.y ) , 0.0 , 0.0));
			float4 tex2DNode86 = tex2D( _MainTex, appendResult76.xy );
			float3 temp_cast_28 = (0.0).xxx;
			float3 break236 = lerp(temp_cast_28,tex2DNode69,_DistortOverlay);
			float mulTime33 = _Time.y * 0.1;
			float4 appendResult32 = (float4(_OverlayScrollingX , _OverlayScrollingY , 0.0 , 0.0));
			float2 uv_Overlay = i.uv_texcoord * _Overlay_ST.xy + _Overlay_ST.zw;
			float2 panner35 = ( mulTime33 * appendResult32.xy + uv_Overlay);
			float2 break83 = panner35;
			float4 appendResult80 = (float4(( break236.x + break83.x ) , ( break83.y + break236.y ) , 0.0 , 0.0));
			float4 tex2DNode37 = tex2D( _Overlay, appendResult80.xy );
			float4 lerpResult8 = lerp( ( ( tex2DNode86 * _MainColor ) * _MainStrength ) , ( ( tex2DNode37 * _OverlayColor ) * _OverlayStrength ) , _Blend);
			float3 temp_cast_31 = (i.viewDir.x).xxx;
			float dotResult157 = dot( i.viewDir , temp_cast_31 );
			float4 lerpResult168 = lerp( lerpResult8 , ( lerpResult8 * ( ( ( 1.0 - dotResult157 ) * _FakeLightStrength ) * _FakeLightColor ) ) , _FakeLightAmount);
			float3 normalizeResult135 = normalize( i.viewDir );
			float dotResult147 = dot( float4(0,0,1,0) , float4( normalizeResult135 , 0.0 ) );
			float mulTime222 = _Time.y * 0.1;
			float2 appendResult223 = (float2(_ScrollRimX , _ScrollRimY));
			float2 uv_RimLightTexture = i.uv_texcoord * _RimLightTexture_ST.xy + _RimLightTexture_ST.zw;
			float2 panner224 = ( mulTime222 * appendResult223 + uv_RimLightTexture);
			float2 break225 = panner224;
			float3 temp_cast_33 = (0.0).xxx;
			float3 break238 = lerp(temp_cast_33,tex2DNode69,_DistortRim);
			float4 appendResult226 = (float4(( break225.x + break238.x ) , ( break238.y + break225.y ) , 0.0 , 0.0));
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult307 = dot( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalMapStrength ) )) , ase_worldlightDir );
			float2 temp_cast_35 = (saturate( (dotResult307*_Scale + _Offset) )).xx;
			float3 In0323 = float4(0,0,0,1).xyz;
			float3 localMyCustomExpression323 = MyCustomExpression323( In0323 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ( lerp(lerpResult168,( lerpResult168 + ( pow( ( 1.0 - saturate( dotResult147 ) ) , _RimLightStrength ) * _RimLightColor * tex2D( _RimLightTexture, appendResult226.xy ) ) ),_EnableRimLight) * tex2D( _ToonRamp, temp_cast_35 ) * _Brightness ) * ( float4( localMyCustomExpression323 , 0.0 ) + ( ase_lightColor * ase_lightAtten ) ) ).rgb;
			c.a = 1;
			clip( ( saturate( ( ( grayscale93 * _MaterializationAmount ) + ( _MaterializationAmount + -4.0 ) ) ) * lerp(1.0,( tex2DNode86.a * _CutoutAmount ),_EnableCutoutMain) * lerp(1.0,( tex2DNode37.a * _CutoutAmount ),_EnableCutoutOverlay) ) - _Cutoff );
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
			float mulTime6 = _Time.y * 0.1;
			float4 appendResult27 = (float4(_MainScrollingX , _MainScrollingY , 0.0 , 0.0));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner7 = ( mulTime6 * appendResult27.xy + uv_MainTex);
			float2 break74 = panner7;
			float3 temp_cast_1 = (0.0).xxx;
			float mulTime65 = _Time.y * 0.1;
			float4 appendResult66 = (float4(_DistortScrollingX , _DistortScrollingY , 0.0 , 0.0));
			float2 uv_DistortTexture = i.uv_texcoord * _DistortTexture_ST.xy + _DistortTexture_ST.zw;
			float2 panner67 = ( mulTime65 * appendResult66.xy + uv_DistortTexture);
			float3 tex2DNode69 = UnpackScaleNormal( tex2D( _DistortTexture, panner67 ), _DistortionStrength );
			float3 break234 = lerp(temp_cast_1,tex2DNode69,_DistortMain);
			float4 appendResult76 = (float4(( break74.x + break234.x ) , ( break74.y + break234.y ) , 0.0 , 0.0));
			float4 tex2DNode86 = tex2D( _MainTex, appendResult76.xy );
			float3 temp_cast_4 = (0.0).xxx;
			float3 break236 = lerp(temp_cast_4,tex2DNode69,_DistortOverlay);
			float mulTime33 = _Time.y * 0.1;
			float4 appendResult32 = (float4(_OverlayScrollingX , _OverlayScrollingY , 0.0 , 0.0));
			float2 uv_Overlay = i.uv_texcoord * _Overlay_ST.xy + _Overlay_ST.zw;
			float2 panner35 = ( mulTime33 * appendResult32.xy + uv_Overlay);
			float2 break83 = panner35;
			float4 appendResult80 = (float4(( break236.x + break83.x ) , ( break83.y + break236.y ) , 0.0 , 0.0));
			float4 tex2DNode37 = tex2D( _Overlay, appendResult80.xy );
			float4 lerpResult8 = lerp( ( ( tex2DNode86 * _MainColor ) * _MainStrength ) , ( ( tex2DNode37 * _OverlayColor ) * _OverlayStrength ) , _Blend);
			float3 temp_cast_7 = (i.viewDir.x).xxx;
			float dotResult157 = dot( i.viewDir , temp_cast_7 );
			float4 lerpResult168 = lerp( lerpResult8 , ( lerpResult8 * ( ( ( 1.0 - dotResult157 ) * _FakeLightStrength ) * _FakeLightColor ) ) , _FakeLightAmount);
			float3 normalizeResult135 = normalize( i.viewDir );
			float dotResult147 = dot( float4(0,0,1,0) , float4( normalizeResult135 , 0.0 ) );
			float mulTime222 = _Time.y * 0.1;
			float2 appendResult223 = (float2(_ScrollRimX , _ScrollRimY));
			float2 uv_RimLightTexture = i.uv_texcoord * _RimLightTexture_ST.xy + _RimLightTexture_ST.zw;
			float2 panner224 = ( mulTime222 * appendResult223 + uv_RimLightTexture);
			float2 break225 = panner224;
			float3 temp_cast_9 = (0.0).xxx;
			float3 break238 = lerp(temp_cast_9,tex2DNode69,_DistortRim);
			float4 appendResult226 = (float4(( break225.x + break238.x ) , ( break238.y + break225.y ) , 0.0 , 0.0));
			o.Albedo = lerp(lerpResult168,( lerpResult168 + ( pow( ( 1.0 - saturate( dotResult147 ) ) , _RimLightStrength ) * _RimLightColor * tex2D( _RimLightTexture, appendResult226.xy ) ) ),_EnableRimLight).rgb;
			float mulTime247 = _Time.y * 0.1;
			float4 appendResult246 = (float4(_EmissionScrollingX , _EmissionScrollingY , 0.0 , 0.0));
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
			float2 panner248 = ( mulTime247 * appendResult246.xy + uv_EmissionTex);
			float2 break249 = panner248;
			float3 temp_cast_14 = (0.0).xxx;
			float3 break258 = lerp(temp_cast_14,tex2DNode69,_DistortEmission);
			float4 appendResult252 = (float4(break249.x , ( break249.y + break258.y ) , 0.0 , 0.0));
			float4 temp_output_257_0 = ( ( tex2D( _EmissionTex, appendResult252.xy ) * _EmissionColor0 ) * _EmissionStrength );
			float mulTime348 = _Time.y * _PulseSpeed;
			float mulTime355 = _Time.y * _RainbowSpeed;
			float3 hsvTorgb357 = HSVToRGB( float3(mulTime355,_RainbowSaturation,_RainbowSaturation) );
			o.Emission = ( ( lerp(lerpResult168,( lerpResult168 + ( pow( ( 1.0 - saturate( dotResult147 ) ) , _RimLightStrength ) * _RimLightColor * tex2D( _RimLightTexture, appendResult226.xy ) ) ),_EnableRimLight) * _BaseEmission ) + lerp(lerp(temp_output_257_0,saturate( ( ( _PulseBaseBrightness + sin( mulTime348 ) ) * temp_output_257_0 ) ),_EnableEmissionPulse),( lerp(temp_output_257_0,saturate( ( ( _PulseBaseBrightness + sin( mulTime348 ) ) * temp_output_257_0 ) ),_EnableEmissionPulse) * float4( hsvTorgb357 , 0.0 ) ),_EnableEmissionRainbow) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow exclude_path:deferred nofog 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15606
132;153;1666;938;1086.901;681.864;2.784572;True;True
Node;AmplifyShaderEditor.CommentaryNode;60;-4026.121,-77.24084;Float;False;1575.932;575.5436;;19;238;237;229;233;236;234;231;232;235;69;79;67;65;64;66;63;62;61;259;Distort;1,0.8896551,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-3966.025,81.85635;Float;False;Property;_DistortScrollingX;Distort Scrolling X;38;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3862.748,206.2788;Float;False;Constant;_Float4;Float 4;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3961.327,144.8276;Float;False;Property;_DistortScrollingY;Distort Scrolling Y;39;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-3690.421,82.95485;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;78;-2269.452,-199.6461;Float;False;1769.069;381.4662;;16;18;25;26;3;6;27;4;7;74;77;75;76;19;86;239;240;Main;1,0.3931034,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;64;-3772.71,-27.24076;Float;False;0;69;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;65;-3720.429,210.4784;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3538.494,241.1244;Float;False;Property;_DistortionStrength;Distortion Strength;45;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2267.376,30.49993;Float;False;Property;_MainScrollingY;Main Scrolling Y;2;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2267.676,-38.60993;Float;False;Property;_MainScrollingX;Main Scrolling X;1;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2177.993,102.5128;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;67;-3554.304,59.25123;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-2034.955,96.48243;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;241;-2260.115,-654.1979;Float;False;1769.069;381.4662;;16;257;256;255;254;253;252;251;250;249;248;247;246;245;244;243;242;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2093.77,-152.1261;Float;False;0;86;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;84;-2284.965,207.4043;Float;False;1788.384;390.8655;;18;80;81;82;83;34;35;36;38;40;29;31;30;33;32;37;39;480;485;Overlay;1,0.5294118,0.5294118,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-2009.415,-35.16861;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-3235.512,-37.88104;Float;False;Constant;_Float3;Float 3;32;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-3370.048,30.75852;Float;True;Property;_DistortTexture;Distort Texture;37;0;Create;True;0;0;False;0;None;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;243;-2258.039,-424.0519;Float;False;Property;_EmissionScrollingY;Emission Scrolling Y;18;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;7;-1863.674,-150.8605;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;232;-3017.105,-42.92697;Float;False;Property;_DistortMain;Distort Main;40;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2276.806,360.6819;Float;False;Property;_OverlayScrollingX;Overlay Scrolling X;6;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-2258.339,-493.1618;Float;False;Property;_EmissionScrollingX;Emission Scrolling X;17;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-2168.655,-352.039;Float;False;Constant;_Float6;Float 6;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2183.78,499.196;Float;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2279.657,432.24;Float;False;Property;_OverlayScrollingY;Overlay Scrolling Y;7;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;153;-2110.287,1145.901;Float;False;1610.641;744.366;;22;220;221;219;222;223;218;224;225;134;177;135;147;137;138;139;228;227;226;217;142;140;141;Rim Light;0,0.7517242,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-2014.015,363.0618;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-2101.15,244.8989;Float;False;0;37;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;220;-2100.515,1736.971;Float;False;Property;_ScrollRimY;Scroll Rim Y;34;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-2101.265,1667.851;Float;False;Property;_ScrollRimX;Scroll Rim X;33;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-2027.525,1811.678;Float;False;Constant;_Float7;Float 7;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-2040.18,503.3967;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;247;-2025.618,-358.0694;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;245;-2084.432,-606.6779;Float;False;0;254;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;246;-2000.078,-489.7205;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-1695.761,-158.228;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;234;-2674.575,-46.66803;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;218;-1951.433,1555.114;Float;False;0;217;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;134;-1912.248,1177.237;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;222;-1886.761,1815.588;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;223;-1840.002,1671.759;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;248;-1854.337,-605.4123;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;35;-1876.527,244.5433;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1457.917,-62.0535;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-1456.526,-157.3642;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;231;-3018.076,48.16293;Float;False;Property;_DistortOverlay;Distort Overlay;41;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;170;-1496.313,1958.02;Float;False;1019.957;424.1697;;7;203;157;162;155;196;166;161;Fake Light;0,1,0.08965492,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;259;-3026.744,329.4105;Float;False;Property;_DistortEmission;Distort Emission;44;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;224;-1712.442,1585.616;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;135;-1724.243,1181.247;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;83;-1707.872,245.9083;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;236;-2677.509,63.17446;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;203;-1479.02,2003.27;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;229;-3020.911,228.9978;Float;False;Property;_DistortRim;DistortRim;43;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;177;-1681.82,1362.463;Float;False;Constant;_Color0;Color 0;25;0;Create;True;0;0;False;0;0,0,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;249;-1686.424,-612.7798;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;258;-2669.957,385.9505;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;76;-1337.589,-157.3289;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;225;-1544.432,1578.423;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;86;-1209.096,-160.433;Float;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;None;8e1dfbb7dff89e94da8232c7cfc37b78;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;250;-1448.58,-516.6053;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;238;-2676.043,278.4662;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;157;-1271.412,2000.275;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;147;-1488.277,1179.605;Float;True;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-1470.787,238.1052;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-1467.936,319.1107;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;240;-1130.162,26.65393;Float;False;Property;_MainColor;Main Color;4;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;137;-1294.248,1179.288;Float;True;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;228;-1313.689,1672.535;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;227;-1308.67,1577.711;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-1171.28,2213.799;Float;False;Property;_FakeLightStrength;Fake Light Strength;47;0;Create;True;0;0;False;0;1;0;-5;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;196;-1059.4,1999.193;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-884.9797,54.82156;Float;False;Property;_MainStrength;Main Strength;3;0;Create;True;0;0;False;0;1;1;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-762.6945,-164.0667;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-1352.602,246.2399;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;252;-1328.252,-611.8807;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-1244.288,1388.316;Float;False;Property;_RimLightStrength;Rim Light Strength;35;0;Create;True;0;0;False;0;0;0;-1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;253;-1004.702,-432.8392;Float;False;Property;_EmissionColor0;EmissionColor0;19;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;162;-914.6732,2210.762;Float;False;Property;_FakeLightColor;Fake Light Color;48;0;Create;True;0;0;False;0;0.4705882,0.4705882,0.4705882,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;254;-1199.759,-614.9848;Float;True;Property;_EmissionTex;EmissionTex;15;0;Create;True;0;0;False;0;None;None;True;0;True;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-625.5849,-169.9213;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;37;-1075.862,241.9416;Float;True;Property;_Overlay;Overlay;5;0;Create;True;0;0;False;0;None;1c2004b10ac9d5643a0d6c4f7a2ded4d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-876.074,1996.772;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-997.7796,427.7478;Float;False;Property;_OverlayColor;Overlay Color;9;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;226;-1185.19,1595.026;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;139;-1138.364,1180.742;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;217;-1051.963,1558.756;Float;True;Property;_RimLightTexture;RimLight Texture;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-768.6816,240.3773;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-753.3572,-618.6185;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-670.5592,1994.35;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;142;-937.7441,1394.033;Float;False;Property;_RimLightColor;Rim Light Color;36;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-749.3033,335.709;Float;False;Property;_OverlayStrength;Overlay Strength;8;0;Create;True;0;0;False;0;1;1;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;375;353.1866,-147.9086;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;140;-958.3623,1183.838;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-800.0222,-504.8577;Float;False;Property;_EmissionStrength;Emission Strength;16;0;Create;True;0;0;False;0;0;1.7;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-616.2478,-624.473;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;411;-130.1731,2023.202;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;376;372.2374,-104.3632;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-688.8279,1181.826;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-618.6235,239.6149;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;390;-438.7908,-580.6403;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;412;-130.1732,1974.244;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;399;-475.1625,1173.271;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;345;387.1342,-592.0408;Float;False;820.4377;195.5317;Comment;11;335;350;352;351;349;348;347;346;418;458;459;Pulse;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;385;353.1908,282.1005;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;374;364.0729,64.37477;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;185;-2807.734,637.0452;Float;False;2313.071;473.76;;19;183;184;182;181;179;178;180;215;213;212;214;87;93;96;128;127;121;132;216;Materialization;0.9034481,0,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-2714.99,926.9735;Float;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-2803.564,860.8622;Float;False;Property;_MaterializationScollingY;Materialization Scolling Y;28;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;399.7143,-559.0499;Float;False;Property;_PulseBaseBrightness;Pulse Base Brightness;22;0;Create;True;0;0;False;0;1.3;1;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;397;-468.8307,419.7888;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-2801.78,793.5565;Float;False;Property;_MaterializationScrollingX;Materialization Scrolling X;27;0;Create;True;0;0;False;0;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;373;369.5162,121.528;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;413;-115.1096,249.467;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;100.3954,89.38421;Float;False;Property;_Blend;Blend;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;389;-436.0691,-539.8162;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;384;391.2929,276.6573;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;398;-443.5035,397.6277;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;414;-58.6213,241.9353;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;179;-2539.667,793.1553;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;178;-2678.922,675.4647;Float;False;0;87;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;8;440.4385,99.60635;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;392;-446.9554,-327.533;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;181;-2563.673,926.6761;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;349;652.0189,-562.7658;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;640.1696,194.0016;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;458;676.2291,-567.0959;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;388;-441.5124,-275.8228;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;396;981.1478,407.1252;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;421;606.5991,127.2766;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;180;-2373.564,676.5057;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;233;-3018.753,137.8678;Float;False;Property;_DistortMaterialization;Distort Materialization;42;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;346;398.9313,-485.9098;Float;False;Property;_PulseSpeed;Pulse Speed;21;0;Create;True;0;0;False;0;2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;511.3878,287.5562;Float;False;Property;_FakeLightAmount;Fake Light Amount;46;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;289;86.31993,910.4144;Float;False;1852.322;485.8294;Comment;12;310;329;327;326;319;315;307;306;302;301;300;295;Toon Light System;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;168;827.3679,97.32292;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;295;100.4933,1035.181;Float;False;Property;_NormalMapStrength;Normal Map Strength;51;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;393;1028.271,-287.8051;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;237;-2673.115,170.0881;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;348;674.889,-531.2509;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;395;990.6456,350.1393;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;215;-2201.15,671.2485;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;459;905.2291,-564.0959;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;300;370.5653,986.8997;Float;True;Property;_NormalMap;Normal Map;50;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;212;-1953.78,667.0445;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;350;831.7488,-532.3709;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;1088.25,279.7704;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;415;1128.741,158.7033;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;-1952.574,756.0621;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;394;1033.993,-313.6289;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;351;922.6086,-560.902;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;302;657.2036,1205.168;Float;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;352;958.4144,-557.474;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;301;665.8907,987.1026;Float;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;353;557.5267,-916.6168;Float;False;647.8328;295.6305;Comment;4;357;356;355;354;Emission rainbow;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;418;1035.663,-458.2039;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;175;1237.489,174.9538;Float;False;Property;_EnableRimLight;Enable Rim Light;31;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;214;-1832.458,670.7821;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;306;950.4744,1199.812;Float;False;Property;_Scale;Scale;54;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;87;-1699.34,677.0789;Float;True;Property;_MaterializationTexture;Materialization Texture;26;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;354;565.0038,-878.5229;Float;False;Property;_RainbowSpeed;Rainbow Speed;24;0;Create;True;0;0;False;0;0.3;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;307;908.2686,985.8389;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;310;947.4883,1277.748;Float;False;Property;_Offset;Offset;53;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;1084.376,-555.3384;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;485;-777.6409,452.778;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;436;1456.556,781.5308;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;93;-1385.376,675.5626;Float;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1459.12,892.9202;Float;True;Property;_MaterializationAmount;Materialization Amount;29;0;Create;True;0;0;False;0;5;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;480;-740.271,459.4097;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1197.026,975.6219;Float;False;Constant;_Float5;Float 5;18;0;Create;True;0;0;False;0;-4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;723.339,-807.8001;Float;False;Property;_RainbowSaturation;Rainbow Saturation;25;0;Create;True;0;0;False;0;0.8;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;355;830.4142,-880.627;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;434;1454.605,-86.05338;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;313;1341.94,1423.867;Float;False;605.9088;379.9005;Comment;6;331;324;323;317;316;457;Ambient Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;437;1474.101,810.7753;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;315;1124.726,986.6915;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;416;1594.104,-512.3987;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;362;1624.316,-478.1758;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;357;990.8838,-882.566;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1047.281,672.9369;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;317;1379.561,1461.96;Float;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;479;-357.4076,453.8305;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;319;1362.581,986.7374;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-1045.092,877.7763;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;439;1708.057,804.9266;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;483;-276.1358,-31.13855;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;435;1495.547,-89.95258;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;457;1349.369,1721.955;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;370;-433.4128,-574.5114;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;316;1400.369,1621.575;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;433;2265.65,-84.10371;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;337;2028.665,40.85368;Float;False;426.5733;128.5706;Comment;2;341;340;Base Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;1623.757,1532.584;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;438;1756.797,808.8256;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;484;-245.2524,-29.89894;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;326;1500.429,962.1144;Float;True;Property;_ToonRamp;Toon Ramp;52;0;Create;True;0;0;False;0;58538042859270c4496e6dd4447c0434;58538042859270c4496e6dd4447c0434;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;363;1618.072,243.586;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;372;-471.5581,316.952;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-817.0226,669.7032;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;323;1560.562,1462.938;Float;False;return ShadeSH9(float4(0,0,0,1))@;3;False;1;True;In0;FLOAT3;0,0,0;In;;My Custom Expression;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;327;1518.735,1152.864;Float;False;Property;_Brightness;Brightness;49;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;359;1946.25,-844.5065;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;478;-307.5352,462.1424;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;481;-242.2378,579.1788;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;360;1956.386,-816.4056;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;336;1659.256,233.1901;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;371;-432.8091,346.0107;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;477;-305.2735,672.1679;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;2032.74,94.25374;Float;False;Property;_BaseEmission;Base Emission;10;0;Create;True;0;0;False;0;0;0.073;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;331;1758.772,1457.426;Float;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;432;2308.542,-64.60742;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;1817.788,945.0209;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;216;-619.2603,669.9665;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;474;-413.3817,502.2377;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;358;1998.458,220.0871;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;447;1248.57,613.2895;Float;False;Property;_CutoutAmount;CutoutAmount;14;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;338;1810.463,312.5595;Float;False;Property;_EnableEmissionPulse;Enable Emission Pulse;20;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;403;2016.394,1455.036;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;476;-278.6974,676.0318;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;482;-203.4486,584.7201;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;2332.161,77.24678;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;400;1975.237,967.4882;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;419;2461.757,122.8303;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;446;1554.79,653.9639;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;475;-376.803,496.8831;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;2086.441,258.6214;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;405;1992.37,622.2345;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;445;1555.116,555.001;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;401;1965.74,590.7468;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;402;1986.428,576.2205;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;420;2456.333,309.9497;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;473;1913.991,481.5373;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;404;2000.568,600.2446;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;365;2606.276,217.6671;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;342;2233.285,315.1339;Float;False;Property;_EnableEmissionRainbow;Enable Emission Rainbow;23;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;442;1688.552,636.0176;Float;False;Property;_EnableCutoutOverlay;EnableCutoutOverlay;12;0;Create;True;0;0;False;0;0;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;441;1702.422,530.8834;Float;False;Property;_EnableCutoutMain;EnableCutoutMain;13;0;Create;True;0;0;False;0;0;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-1447.189,-611.916;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;364;2632.91,275.785;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;334;2513.214,556.0862;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;343;2516.221,299.6058;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;1987.567,448.6644;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;15;2684.487,253.5341;Float;False;True;3;Float;ASEMaterialInspector;0;0;CustomLighting;Zer0/Customs V3 Toon;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;True;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;30;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;66;0;61;0
WireConnection;66;1;63;0
WireConnection;65;0;62;0
WireConnection;67;0;64;0
WireConnection;67;2;66;0
WireConnection;67;1;65;0
WireConnection;6;0;3;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;69;1;67;0
WireConnection;69;5;79;0
WireConnection;7;0;4;0
WireConnection;7;2;27;0
WireConnection;7;1;6;0
WireConnection;232;0;235;0
WireConnection;232;1;69;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;33;0;29;0
WireConnection;247;0;242;0
WireConnection;246;0;244;0
WireConnection;246;1;243;0
WireConnection;74;0;7;0
WireConnection;234;0;232;0
WireConnection;222;0;221;0
WireConnection;223;0;219;0
WireConnection;223;1;220;0
WireConnection;248;0;245;0
WireConnection;248;2;246;0
WireConnection;248;1;247;0
WireConnection;35;0;34;0
WireConnection;35;2;32;0
WireConnection;35;1;33;0
WireConnection;77;0;74;1
WireConnection;77;1;234;1
WireConnection;75;0;74;0
WireConnection;75;1;234;0
WireConnection;231;0;235;0
WireConnection;231;1;69;0
WireConnection;259;0;235;0
WireConnection;259;1;69;0
WireConnection;224;0;218;0
WireConnection;224;2;223;0
WireConnection;224;1;222;0
WireConnection;135;0;134;0
WireConnection;83;0;35;0
WireConnection;236;0;231;0
WireConnection;229;0;235;0
WireConnection;229;1;69;0
WireConnection;249;0;248;0
WireConnection;258;0;259;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;225;0;224;0
WireConnection;86;1;76;0
WireConnection;250;0;249;1
WireConnection;250;1;258;1
WireConnection;238;0;229;0
WireConnection;157;0;203;0
WireConnection;157;1;203;1
WireConnection;147;0;177;0
WireConnection;147;1;135;0
WireConnection;82;0;236;0
WireConnection;82;1;83;0
WireConnection;81;0;83;1
WireConnection;81;1;236;1
WireConnection;137;0;147;0
WireConnection;228;0;238;1
WireConnection;228;1;225;1
WireConnection;227;0;225;0
WireConnection;227;1;238;0
WireConnection;196;0;157;0
WireConnection;239;0;86;0
WireConnection;239;1;240;0
WireConnection;80;0;82;0
WireConnection;80;1;81;0
WireConnection;252;0;249;0
WireConnection;252;1;250;0
WireConnection;254;1;252;0
WireConnection;18;0;239;0
WireConnection;18;1;19;0
WireConnection;37;1;80;0
WireConnection;166;0;196;0
WireConnection;166;1;155;0
WireConnection;226;0;227;0
WireConnection;226;1;228;0
WireConnection;139;0;137;0
WireConnection;217;1;226;0
WireConnection;39;0;37;0
WireConnection;39;1;36;0
WireConnection;256;0;254;0
WireConnection;256;1;253;0
WireConnection;161;0;166;0
WireConnection;161;1;162;0
WireConnection;375;0;18;0
WireConnection;140;0;139;0
WireConnection;140;1;138;0
WireConnection;257;0;256;0
WireConnection;257;1;255;0
WireConnection;411;0;161;0
WireConnection;376;0;375;0
WireConnection;141;0;140;0
WireConnection;141;1;142;0
WireConnection;141;2;217;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;390;0;257;0
WireConnection;412;0;411;0
WireConnection;399;0;141;0
WireConnection;385;0;40;0
WireConnection;374;0;376;0
WireConnection;397;0;399;0
WireConnection;373;0;374;0
WireConnection;413;0;412;0
WireConnection;389;0;390;0
WireConnection;384;0;385;0
WireConnection;398;0;397;0
WireConnection;414;0;413;0
WireConnection;179;0;184;0
WireConnection;179;1;183;0
WireConnection;8;0;373;0
WireConnection;8;1;384;0
WireConnection;8;2;24;0
WireConnection;392;0;389;0
WireConnection;181;0;182;0
WireConnection;349;0;347;0
WireConnection;167;0;8;0
WireConnection;167;1;414;0
WireConnection;458;0;349;0
WireConnection;388;0;392;0
WireConnection;396;0;398;0
WireConnection;421;0;8;0
WireConnection;180;0;178;0
WireConnection;180;2;179;0
WireConnection;180;1;181;0
WireConnection;233;0;235;0
WireConnection;233;1;69;0
WireConnection;168;0;421;0
WireConnection;168;1;167;0
WireConnection;168;2;169;0
WireConnection;393;0;388;0
WireConnection;237;0;233;0
WireConnection;348;0;346;0
WireConnection;395;0;396;0
WireConnection;215;0;180;0
WireConnection;459;0;458;0
WireConnection;300;5;295;0
WireConnection;212;0;215;0
WireConnection;212;1;237;0
WireConnection;350;0;348;0
WireConnection;148;0;168;0
WireConnection;148;1;395;0
WireConnection;415;0;168;0
WireConnection;213;0;237;1
WireConnection;213;1;215;1
WireConnection;394;0;393;0
WireConnection;351;0;459;0
WireConnection;352;0;351;0
WireConnection;352;1;350;0
WireConnection;301;0;300;0
WireConnection;418;0;394;0
WireConnection;175;0;415;0
WireConnection;175;1;148;0
WireConnection;214;0;212;0
WireConnection;214;1;213;0
WireConnection;87;1;214;0
WireConnection;307;0;301;0
WireConnection;307;1;302;0
WireConnection;335;0;352;0
WireConnection;335;1;418;0
WireConnection;485;0;37;4
WireConnection;436;0;175;0
WireConnection;93;0;87;0
WireConnection;480;0;485;0
WireConnection;355;0;354;0
WireConnection;434;0;175;0
WireConnection;437;0;436;0
WireConnection;315;0;307;0
WireConnection;315;1;306;0
WireConnection;315;2;310;0
WireConnection;416;0;335;0
WireConnection;362;0;416;0
WireConnection;357;0;355;0
WireConnection;357;1;356;0
WireConnection;357;2;356;0
WireConnection;121;0;93;0
WireConnection;121;1;96;0
WireConnection;479;0;480;0
WireConnection;319;0;315;0
WireConnection;127;0;96;0
WireConnection;127;1;128;0
WireConnection;439;0;437;0
WireConnection;483;0;86;4
WireConnection;435;0;434;0
WireConnection;370;0;257;0
WireConnection;433;0;435;0
WireConnection;324;0;316;0
WireConnection;324;1;457;0
WireConnection;438;0;439;0
WireConnection;484;0;483;0
WireConnection;326;1;319;0
WireConnection;363;0;362;0
WireConnection;372;0;370;0
WireConnection;132;0;121;0
WireConnection;132;1;127;0
WireConnection;323;0;317;0
WireConnection;359;0;357;0
WireConnection;478;0;479;0
WireConnection;481;0;484;0
WireConnection;360;0;359;0
WireConnection;336;0;363;0
WireConnection;371;0;372;0
WireConnection;477;0;478;0
WireConnection;331;0;323;0
WireConnection;331;1;324;0
WireConnection;432;0;433;0
WireConnection;329;0;438;0
WireConnection;329;1;326;0
WireConnection;329;2;327;0
WireConnection;216;0;132;0
WireConnection;474;0;216;0
WireConnection;358;0;360;0
WireConnection;338;0;371;0
WireConnection;338;1;336;0
WireConnection;403;0;331;0
WireConnection;476;0;477;0
WireConnection;482;0;481;0
WireConnection;341;0;432;0
WireConnection;341;1;340;0
WireConnection;400;0;329;0
WireConnection;419;0;341;0
WireConnection;446;0;476;0
WireConnection;446;1;447;0
WireConnection;475;0;474;0
WireConnection;339;0;338;0
WireConnection;339;1;358;0
WireConnection;405;0;403;0
WireConnection;445;0;482;0
WireConnection;445;1;447;0
WireConnection;401;0;400;0
WireConnection;402;0;401;0
WireConnection;420;0;419;0
WireConnection;473;0;475;0
WireConnection;404;0;405;0
WireConnection;365;0;175;0
WireConnection;342;0;338;0
WireConnection;342;1;339;0
WireConnection;442;1;446;0
WireConnection;441;1;445;0
WireConnection;251;0;249;0
WireConnection;251;1;258;0
WireConnection;364;0;365;0
WireConnection;334;0;402;0
WireConnection;334;1;404;0
WireConnection;343;0;420;0
WireConnection;343;1;342;0
WireConnection;472;0;473;0
WireConnection;472;1;441;0
WireConnection;472;2;442;0
WireConnection;15;0;364;0
WireConnection;15;2;343;0
WireConnection;15;10;472;0
WireConnection;15;13;334;0
ASEEND*/
//CHKSM=8C3CE9021F302DE68302CE039F8E847742852A57