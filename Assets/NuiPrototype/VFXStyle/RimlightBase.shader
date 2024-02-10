// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/SwordTip"
{
	Properties
	{
		_SmoothStep("SmoothStep", Vector) = (0,1,0,0)
		[HDR]_RimColor("RimColor", Color) = (0,0,0,0)
		_BaseColor("BaseColor", Color) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend One One
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform float4 _BaseColor;
		uniform float4 _RimColor;
		uniform float2 _SmoothStep;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float smoothstepResult4 = smoothstep( _SmoothStep.x , _SmoothStep.y , length( ( 1.0 - i.viewDir.z ) ));
			o.Emission = ( _BaseColor + ( _RimColor * saturate( smoothstepResult4 ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.SmoothstepOpNode;4;-237.5,66.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-492.5,300.5;Inherit;False;Property;_SmoothStep;SmoothStep;1;0;Create;True;0;0;0;False;0;False;0,1;0.21,0.72;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;6;6.5,31.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;255.5,17.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;-50.5,-206.5;Inherit;False;Property;_RimColor;RimColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.8130614,1.741101,1.398211,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;3;-466.5,54.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-636.5,-10.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-873.5,9.5;Inherit;True;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;613,52;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Unlit/SwordTip;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;470.5,-57.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;11;286.5,-238.5;Inherit;False;Property;_BaseColor;BaseColor;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;4;0;3;0
WireConnection;4;1;5;1
WireConnection;4;2;5;2
WireConnection;6;0;4;0
WireConnection;7;0;8;0
WireConnection;7;1;6;0
WireConnection;3;0;9;0
WireConnection;9;0;1;3
WireConnection;0;2;10;0
WireConnection;10;0;11;0
WireConnection;10;1;7;0
ASEEND*/
//CHKSM=B4D2B0062A7297716F979D20B847CAC1AC9C7D08