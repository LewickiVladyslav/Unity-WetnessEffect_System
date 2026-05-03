using UnityEngine;
using UnityEngine.Rendering;

public class WetnessSystem : MonoBehaviour
{
    public Renderer sourceRenderer;
    public Material wetnessMaterial;
    public Renderer[] applyToRenderers;
    public string wetMaskName = "Wetness_Mask";

    public int rTSize = 512;
    public RenderTextureFormat rTFormat = RenderTextureFormat.RHalf;

    public float waterLevel = 1f;
    public float dryTimeSeconds = 5f;

    const float tick = 60f;
    const float tickDt = 1f / tick;
    const int maxSteps = 6;

    static readonly int WaterLevelId = Shader.PropertyToID("WaterLevel");
    static readonly int PrevMaskId = Shader.PropertyToID("PrevMask");
    static readonly int DryCoefId = Shader.PropertyToID("DryCoef");
    static readonly int DeltaTimeId = Shader.PropertyToID("DeltaTime");

    CommandBuffer cb;
    MaterialPropertyBlock mpb;
    int wetPropId;

    RenderTexture a, b;
    bool useA = true;
    float acc;

    void OnEnable()
    {
        cb = new CommandBuffer();
        mpb = new MaterialPropertyBlock();
        wetPropId = Shader.PropertyToID(wetMaskName);

        if (!sourceRenderer) sourceRenderer = GetComponent<Renderer>();
        if (applyToRenderers == null || applyToRenderers.Length == 0) applyToRenderers = new[] { sourceRenderer };

        a = NewRT("WetA"); b = NewRT("WetB");
        a.Create(); b.Create();
        Clear(a); Clear(b);
    }

    void OnDisable()
    {
        cb?.Release(); cb = null;
        Kill(a); Kill(b);
    }

    void LateUpdate()
    {
        if (!sourceRenderer || !wetnessMaterial) return;

        acc += Time.deltaTime;
        int steps = Mathf.Min(Mathf.FloorToInt(acc * tick), maxSteps);
        if (steps <= 0) return;

        float dt = steps * tickDt;
        acc -= dt;

        var prev = useA ? a : b;
        var next = useA ? b : a;

        float dryCoef = (dryTimeSeconds <= 0.01f) ? 9999f : Mathf.Log(50f) / dryTimeSeconds;

        cb.Clear();
        cb.Blit(prev, next);

        wetnessMaterial.SetTexture(PrevMaskId, prev);
        wetnessMaterial.SetFloat(WaterLevelId, waterLevel);
        wetnessMaterial.SetFloat(DryCoefId, dryCoef);
        wetnessMaterial.SetFloat(DeltaTimeId, dt);

        cb.SetRenderTarget(next);

        int sub = SubMeshes(sourceRenderer);
        for (int i = 0; i < sub; i++) cb.DrawRenderer(sourceRenderer, wetnessMaterial, i);

        Graphics.ExecuteCommandBuffer(cb);

        for (int i = 0; i < applyToRenderers.Length; i++)
        {
            var r = applyToRenderers[i];
            if (!r) continue;
            r.GetPropertyBlock(mpb);
            mpb.SetTexture(wetPropId, next);
            r.SetPropertyBlock(mpb);
        }
        useA = !useA;
    }

    RenderTexture NewRT(string n) => new RenderTexture(rTSize, rTSize, 0, rTFormat)
    {
        name = $"{n}_{gameObject.name}",
        wrapMode = TextureWrapMode.Clamp,
        filterMode = FilterMode.Bilinear,
        useMipMap = false,
        autoGenerateMips = false
    };

    static void Kill(RenderTexture rt)
    {
        if (!rt) return;
        if (rt.IsCreated()) rt.Release();
        Destroy(rt);
    }

    static void Clear(RenderTexture rt)
    {
        var prev = RenderTexture.active;
        RenderTexture.active = rt;
        GL.Clear(false, true, Color.black);
        RenderTexture.active = prev;
    }

    static int SubMeshes(Renderer r)
    {
        if (!r) return 1;
        if (r is SkinnedMeshRenderer smr && smr.sharedMesh) return Mathf.Max(1, smr.sharedMesh.subMeshCount);
        var mf = r.GetComponent<MeshFilter>();
        if (mf && mf.sharedMesh) return Mathf.Max(1, mf.sharedMesh.subMeshCount);
        return 1;
    }
}