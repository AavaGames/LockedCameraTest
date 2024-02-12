using System.Collections;
using UnityEngine;

namespace Assets.App.Scripts.Extensions
{
    public static class IntExtension
    {
        /// <summary>
        /// Recursively wraps the index to fit into the array (Example: index = 5, arrayLength = 5, returns 0)
        /// </summary>
        public static int WrapIndex(int index, int arrayLength)
        {
            if (index >= arrayLength)
            {
                index -= arrayLength;
                return WrapIndex(index, arrayLength);
            }
            else if (index < 0)
            {
                index += arrayLength;
                return WrapIndex(index, arrayLength);
            }
            return index;
        }
    }
}